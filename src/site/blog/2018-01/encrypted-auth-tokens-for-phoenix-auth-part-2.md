---
title: "Encrypted auth tokens for Phoenix (Auth part 2)"
date: 2018-01-08
---

Last time, in [Tokens, cookies and sessions: an auth story (Part 1)](https://sealas.at/blog/2017-12/tokens-cookies-and-sessions-an-auth-story-part-1/), we talked about the decision-making process behind our authentication mechanism.

This post will explore the implementation of our very own authentication token library, which you can find here on [Github](https://github.com/Brainsware/authtoken).

We will go over fleshing out an API for working directly with auth tokens, talk about expiring and refreshing tokens.
At the end we'll cover a router plug to use in a Phoenix project.

## What is your function in life?

To set our goals and aims straight, let's keep in mind what we want to do: simple encrypted tokens as means for authentication, which will serve as the baseline which we can improve upon in the future.
Out of all the options that are available within JWT, we want to have _one_ sane setting, that will sufficiently secure our tokens.

With that in mind, we can safely set the mode we use to A128GCM, and pass on the key directly.

### Why AES 128 and not 256?

There are [some](https://www.schneier.com/blog/archives/2009/07/another_new_aes.html) [attacks](https://www.schneier.com/blog/archives/2011/08/new_attack_on_a_1.html) on AES 256 that make it's key handling "weaker" than that of AES 128, but none have any practical security implications, for now.

> *And for new applications I suggest that people don't use AES-256.
AES-128 provides more than enough security margin for the forseeable future.
But if you're already using AES-256, there's no reason to change.
*

Other than this quote from Schneier, AES-128 has the advantage of being slightly faster and slightly smaller in output, while providing a solution that is *secure enough*.
Another point to keep in mind: tokens are short lived, so if at any point we should discover that AES-128 isn't secure enough any more, we can simply exchange it for something better.

## Dependencies

Since [JOSE/JWT for Elixir](https://github.com/potatosalad/erlang-jose) is what we're using to create this, and Phoenix is the framework we're building this for, our list of dependencies is going to be pretty straight forward.

```elixir
defp deps do
  [
    {:jose, "~> 1.8"},
    {:plug, "~> 1.4"},
    {:phoenix, "~> 1.3"},
  ]
end
```

Most of the code won't care about Phoenix or Plug, so you can use it in any project you want, independent of your choice of framework, or lack thereof.

## Token API

Let's put together our token API, by first guarding the most basic edges with tests.

### Keys

Encryption usually requires some form of key for the encrypting party, otherwise we would be scrambling into an unrecoverable mess.
AES128 keys need to be 16 bytes in length, so we can simply test for that:

```elixir
describe "keys" do
  test "generate_key/0 returns a valid AES128 key" do
    {:ok, key} = AuthToken.generate_key()

    assert byte_size(key) == 16
  end
end
```

And its very short implementation:

```elixir
@spec generate_key() :: {:ok, binary}
def generate_key do
  {:ok, :crypto.strong_rand_bytes(16)}
end
```

That key then just goes to `config :authtoken, :token_key` so we can read it out with `Application.get_env(:authtoken, :token_key)`.
There is no necessity to make it readable for people, so we can just leave it in its binary format.

### Tokens

Tokens themselves are very simple and so the only part we really need to verify is whether the encryption and decryption works as expected.

```elixir
@user %{id: 123}

describe "tokens" do
  test "token generation" do
    {:ok, encrypted_token} = AuthToken.generate_token(@user)

    assert {:ok, token} = AuthToken.decrypt_token(encrypted_token)
    assert token["id"] == @user.id
  end
end
```

We'll set up some test data to verify with, generate a token and decrypt it again!

Simple, right?

Yes, but not very useful.

### Expiration and refresh

*Intermission: the beauty of **writing down your thoughts **about what you're doing is making it easier to recognize when you're doing something ~~stupid~~suboptimal.
In the first iteration I left out a refresh cycle for the tokens for simplicity's sake.
The huge downside to this is that you're keeping your tokens valid for way longer than is sensible in an environment in which you want to be able to revoke access; by removing someone from a project, by deleting your own or someone else's account, changing permissions or any other reason or set of reasons.*

Any useful token needs to have some limited time frame within which it is valid.
This is also one of those settings that should have some default value which can be overwritten by other applications' config files.
To that end, we can add this to the package's application method in mix.exs:

```elixir
def application do
  [applications: [:logger, :plug],
  env: [
    timeout: 86400,
    refresh: 1800
  ]]
end
```

With these defaults we have the total lifetime of a token set to one day, with a refresh rate of 30 minutes.
This means that a user will need to do provide their credentials only once per day.
The client however needs to request a new token once per refresh cycle - 30 minutes in this case - which denotes the time window of total trust we want to put into a single token.
After that we can refresh the token and use that opportunity to check with the backend if the user is still legible for access.

So, to validate that we have a usable token meeting our requirements, let's extend our test for the tokens:

```elixir
test "token generation" do
  {:ok, encrypted_token} = AuthToken.generate_token(@user)

  assert {:ok, token} = AuthToken.decrypt_token(encrypted_token)
  assert token["id"] == @user.id

  refute AuthToken.is_timedout?(token)
  refute AuthToken.needs_refresh?(token)

  Application.put_env(:authtoken, :timeout, -1)
  Application.put_env(:authtoken, :refresh, -1)

  assert AuthToken.is_timedout?(token)
  assert AuthToken.needs_refresh?(token)
end
```

Newly generated tokens should neither be timed out nor need a refresh, so both `is_timedout?/1` and `needs_refresh?/1`  should return false.
To ensure that both functions actually do their job, we can reduce the time to timeout and refresh to -1, so they always return true and assert that that's happening.

That was easy enough, so now it's

### Implementation time

First let's get dirty and generate some encrypted tokens.
Looking at the [JOSE documentation](https://hexdocs.pm/jose/JOSE.html#content), it is very easy to get overwhelmed and maybe go a bit insane; and get reminded why having a reduced set of options is actually a nice thing, if you don't want to die of choice paralysis.

But since we already know what we're going for, we can just look at what we need for our implementation case.
To generate our token we need an encryption header (JWE):

```elixir
%{ "alg" => "dir", "enc" => "A128GCM", "typ" => "JWT" }
```

which we can just put in a private function `defp get_jwe`.
`alg` set to  `dir` means we don't need any key wrapping or derivation function, since we're supplying our own key in the correct size already.

Second we need a key (JWK), which we can generate with `JOSE.JWK.from_oct/1`.
This we can also put into a private helper function:

```elixir
@spec get_jwk() :: %JOSE.JWK{}
defp get_jwk do
  get_config(:token_key)
  |> JOSE.JWK.from_oct()
end
```

`get_config/1` is a simple wrapper function for `Application.get_env(:authtoken, :atom)` which throws an error if the specified atom is not set.

Alright, with this done, we can piece together a nice and simple function generating us our tokens.

```elixir
@spec generate_token(map) :: {:ok, String.t}
def generate_token(user_data) do
  token_content = %{ct: DateTime.to_unix(DateTime.utc_now())} |> Enum.into(user_data)

  jwt = JOSE.JWT.encrypt(get_jwk(), get_jwe(), token_content) |> JOSE.JWE.compact |> elem(1)

  # Remove JWT header
  {:ok, Regex.run(~r/.+?\.(.+)/, jwt) |> List.last}
end
```

Taking an arbitrary map of data, we insert a creation time, do the conversion and then snip off the token's header by removing everything up to the first `.`  with a quick regex.
Since the library only provides us with standard compliant JWTs, this is the way to go here.

Decrypting our tokens is going to be similarly easy.
We have to rebuild our decapitated token, which we can easily do with our helper function `get_jwe/0`  and a base64 encoding, since all JWTs are base64 encoded.

```elixir
header = get_jwe() |> JOSE.Poison.lexical_encode! |> :base64url.encode

auth_token = header <> "." <> headless_token
```

Now all we need to do is `try do` decrypt with our key, and return

```elixir
try do
  %{fields: token} = JOSE.JWT.decrypt(get_jwk(), auth_token) |> elem(1)

  {:ok, token}
rescue
  _ -> {:error}
end
```

Last but not least we need to add the helper functions for checking the freshness of our tokens.
These would simply read out the configured value for the respective time frames and return either true or false:

```elixir
@spec is_timedout?(map) :: boolean
def is_timedout?(token) do
  {:ok, ct} = DateTime.from_unix(token["ct"])

  DateTime.diff(DateTime.utc_now(), ct) > get_config(:timeout)
end

@spec needs_refresh?(map) :: boolean
def needs_refresh?(token) do
  {:ok, rt} = DateTime.from_unix(token["rt"])

  DateTime.diff(DateTime.utc_now(), rt) > get_config(:refresh)
end
```

### Regeneration

So far so good, what's missing now is a way to refresh stale tokens.
A function providing this should give us a token with the same creation time, but a new refresh time -- if the token actually is eligible for regeneration; so only if it's not still fresh and if it's not timed out.

```elixir
test "token refresh" do
  {:ok, encrypted_token} = AuthToken.generate_token(@user)
  {:ok, token} = AuthToken.decrypt_token(encrypted_token)

  assert AuthToken.refresh_token(token) == {:error, :stillfresh}

  :timer.sleep(1000)

  Application.put_env(:authtoken, :refresh, -1)
  assert {:ok, fresh_token} = AuthToken.refresh_token(token)

  {:ok, token} = AuthToken.decrypt_token(fresh_token)
  assert token["ct"] < token["rt"]

  Application.put_env(:authtoken, :timeout, -1)
  assert AuthToken.refresh_token(token) == {:error, :timedout}
end
```

This covers what we described pretty well, and implementing it should also pretty straight forward, especially given that we already have some working helper functions:

```elixir
@spec refresh_token(map) :: {:ok, String.t} | {:error, :stillfresh} | {:error, :timedout}
def refresh_token(token) do
  cond do
    is_timedout?(token) ->    {:error, :timedout}
    !needs_refresh?(token) -> {:error, :stillfresh}

    needs_refresh?(token) ->
      token = %{"rt" => DateTime.to_unix(DateTime.utc_now())} |> Enum.into(token)

      generate_token(token)
  end
end
```

We can easily increase the usability of this function here by making it possible to directly refresh a still encrypted token you receive from the client.
Elixir's guards make this beautifully elegant.
First let's add one to the existing function:

```elixir
def refresh_token(token) when is_map(token) do
```

Sweet! Now what we need is another function accepting string tokens attempting to decrypt and then refresh them.
Also, I'm going to let you figure out how to extend the test cases for this yourself, and if you want you can even pretend to have written the tests first.

```elixir
@spec refresh_token(String.t) :: {:ok, String.t} | {:error, :stillfresh} | {:error, :timedout}
def refresh_token(token) when is_binary(token) do
  decrypt_token(token)
  |> refresh_token
end
```

## Plug me baby

A plug is what's going to make the whole process of checking tokens easily integrated in our (or our user's) future routers.
We are going to be covering one use-case, that I think is the most common: block all requests with invalid tokens with a `401` and let through (i.e. do nothing) those with valid tokens.

JWTs usually get sent with the `authorization` header with `bearer: ` prefixed.
We'll stick to this standard here.

Again, let's start out with writing down our wishes and requirements in the form of tests.
They're such a useful tool to help you remember what you would like your software to look like when it's all grown up.

### Test for no token existing

The simplest test case is to send a request with no special auth header set:

```elixir
test "denying access for no token", %{conn: conn} do
  conn = AuthToken.Plug.verify_token(conn, [])

  assert json_response(conn, 401)
end
```

### Test for "wrong" token

This could be anything from a malicious token to one so old that your key for generating them has changed a few times already.

```elixir
test "denying access for wrong token", %{conn: conn} do
  conn = conn
  |> put_req_header("authorization", "bearer: ")
  |> AuthToken.Plug.verify_token([])

  assert json_response(conn, 401)
end
```

### Test for stale and expired tokens

For this one, we can again just set the refresh and timeout value to -1, which will make all tokens expire or require regeneration immediately.

```elixir
test "denying access for stale or expired token", %{conn: conn} do
  {:ok, token} = AuthToken.generate_token(@user)

  Application.put_env(:authtoken, :refresh, -1)

  conn = conn
  |> put_req_header("authorization", "bearer: " <> token)
  |> AuthToken.Plug.verify_token([])

  assert json_response(conn, 401) == %{"error" => "needs_refresh"}

  Application.put_env(:authtoken, :timeout, -1)

  assert Application.get_env(:authtoken, :timeout) == -1

  conn = conn
  |> recycle()
  |> put_req_header("authorization", "bearer: " <> token)
  |> AuthToken.Plug.verify_token([])

  assert json_response(conn, 401) == %{"error" => "timeout"}
end
```

### Test for valid tokens

Just generate a token and expect the request to go through.

```elixir
test "granting access for correct token", %{conn: conn} do
  {:ok, token} = AuthToken.generate_token(@user)

  conn = conn
  |> put_req_header("authorization", "bearer: " <> token)
  |> AuthToken.Plug.verify_token([])

  assert conn.status != 401
end
```

### Do it

Having covered a good range of cases, we can attempt to implement this.
If we want this module to be usable as a plug, we have to `import Plug.Conn`, which gives the module access to all the necessary functionality.

First we'll try to verify if the given token is decryptable at all.
Let's extract the token from the request header:

```elixir
token_header = get_req_header(conn, "authorization") |> List.first

crypto_token = if token_header, do: Regex.run(~r/(bearer\: )?(.+)/, token_header) |> List.last
```

We don't need the `bearer: ` portion, so a quick Regex will get rid of that.
Next we can pass it through `AuthToken.decrypt_token/1` and return accordingly.
In case it fails, we send back a `401` with the JSON encoded error message `auth_fail`.
Don't forget to call `halt/0` to tell Plug that this request is done and no further action is needed.
A client can then use this as a keyword for translation or redirect to a login page.
Or crash the browser if it's feeling frisky.

```elixir
case AuthToken.decrypt_token(crypto_token) do
  {:error} ->
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, "{\"error\": \"auth_fail\"}")
    |> halt
  {:ok, token} ->
    conn
end
```

The success case could just end here, but there's still the case of a timed out token, so let's extend that to

```elixir
{:ok, token} ->
  conn |> check_token_time(token)
```

and pass it on to the next method validating the time.
In case it fails here, we're going to return the error message `timeout`.
Apart from that it is pretty similar to `verify_token`.
Here's the full code for both functions:

```elixir
import Plug.Conn

@spec verify_token(Plug.Conn.t, any) :: Plug.Conn.t
def verify_token(conn, _options) do
  token_header = get_req_header(conn, "authorization") |> List.first

  crypto_token = if token_header, do: Regex.run(~r/(bearer\: )?(.+)/, token_header) |> List.last

  case AuthToken.decrypt_token(crypto_token) do
    {:error} ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, "{\"error\": \"auth_fail\"}")
      |> halt
    {:ok, token} ->
      conn |> check_token_time(token)
  end
end

@spec check_token_time(Plug.Conn.t, map) :: Plug.Conn.t
defp check_token_time(conn, token) do
  timeout = AuthToken.get_config(:timeout)

  {:ok, ct} = DateTime.from_unix(token["ct"])

  cond do
    AuthToken.is_timedout?(token) ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, "{\"error\": \"timeout\"}")
      |> halt
    AuthToken.needs_refresh?(token) ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(:unauthorized, "{\"error\": \"needs_refresh\"}")
      |> halt
    true ->
      conn
  end
end
```

## Future Improvements

That's a good base package for our simple encrypted auth tokens.
There is always room for improvement though, and writing down helps with not forgetting future plans.

One thing that could greatly improve usability -- and at the same time security -- would be an automated key management.
Keys could then be kept by the server for the duration of the timeout and then replaced by a new key, thus ensuring constant rotation.

Next time we'll look at assembling what we have into a more complete authentication API.
