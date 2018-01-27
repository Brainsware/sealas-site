---
title: "Designing and writing a basic authentication API with Phoenix and Elixir (Auth Part 3)"
date: 2018-01-26
---

Continuing this series on writing and developing an authentication process with Phoenix and Elixir, so far we've covered developing our authentication library [authtoken](https://github.com/Brainsware/authtoken) in part [1](https://sealas.at/blog/2017-12/tokens-cookies-and-sessions-an-auth-story-part-1/) and [2](https://sealas.at/blog/2018-01/encrypted-auth-tokens-for-phoenix-auth-part-2/).

In this part (#3) we will cover the most basic necessities for a working authentication.
We will cover the basic structure in our app, including a custom ecto type to handle our password hashing and working with our token library.

So, what are we doing here?

APIs provide you with resources you need or want in another part of an application, or in another application entirely.
In the case of Sealas we want to provide our resources through a REST API to our front-end application.
When writing an interface like this, you usually don't want to give everyone access to everything; you want to give each user access specifically to their respective resources.
So let's protect it with a layer of authentication!

## Packages and parts

Our users need to identify themselves via some kind of password, which at no point ever should be stored in cleartext.
To that end, we're going to use a password hashing library: [Comeonin](https://github.com/riverrun/comeonin) with [Argon2](https://github.com/riverrun/argon2_elixir).
For those who don't know, a password hashing library is different from a normal hashing library in that it is as slow as is *sensible* - depending on the system you're on.
This makes bruteforce attacks, i.e.
trying different combinations of passwords until you find a correct one, a lot harder and more resource intensive.

On a testing environment however that is not necessary, so to our `config/test.exs` file we can simply add:

```elixir
config :argon2_elixir,
  t_cost: 2,
  m_cost: 12
```

With that we have our token storage covered.
To make it a bit easier to read our data, I would suggest using [BaseModel](https://github.com/meyercm/base_model), which provides an ActiveRecord like access to your ecto schemas.
It removes a lot of overhead when interacting with your data store.

We're also going to need to include our own authtoken library:

```elixir
{:argon2_elixir, "~> 1.2"},
{:comeonin, "~> 4.0"},
{:base_model, "~> 0.2"},
{:authtoken, "~> 0.2"},
```

At some point in the future we may want to add other parts to our authentication system, like two-factor authentication or email confirmations, but we'll leave that for a later step and article.

## What does the structure look like?

Part of any authentication are three different processes we're going to have to build:

1. Registration for new users
2. Login for existing users
3. Verification for provided authentication tokens

We're definitely going to need to store some user information, and the way to interface to with said store is via a schema.
But before we can access a store, we need to create it:

```shell
mix ecto.gen.migration create_users
```

I'm going to give the user a few more fields and features than just the bare-bones version, containing just an email and password field, but you can simplify or extend from that depending on your needs.

```elixir
defmodule SealasSso.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email,                :string
      add :password,             :string, null: true
      add :password_hint,        :string, null: true
      add :active,               :bool,   default: false
      add :activation_code,      :string, size: 32, null: true

      timestamps()
    end

    create unique_index(:users, [:email])

  end
end
```

Let's go over these fields, to make sure we're all on the same page: Ecto's `create table` automatically adds the field `id` as a table's primary key, so we have that covered.
That makes it easy to avoid the mistake of using non-permanent data like an e-mail address as the primary key.
We do however use it as a user's identification token, so it's necessary to ensure it is unique; thus the additional `unique_index` attached to it.

The password is just a normal text field, but will of course never store a cleartext password.
It is allowed to have a `null` value, because the registration in Sealas is set up as a two-step process.
First you enter your email address, which you then verify and set your password.
This hints at the reason we include fields `active` and `activation_code`: By default a user is deactivated and gets an activation code attached and sent out by email on creation.

For simplicity's sake we'll skip this part for now, but keep these fields in mind.
I'll expand on this part in the next post.

With our migration set, we can go ahead and create a corresponding schema definition.

```elixir
defmodule SealasSso.Accounts.User do
  use BaseModel, repo: SealasSso.Repo
  import Ecto.Changeset

  alias SealasSso.Accounts.User

  schema "users" do
    field :email,                :string
    field :password,             EctoHashedPassword
    field :password_hint,        :string
    field :active,               :boolean, default: false
    field :activation_code,      :string

    timestamps()
  end
end
```

At the top of the file we `use BaseModel` and tell it the repo file we're using.
The schema mirrors our migration file except for `EctoHashedPassword`, which automatically transforms all input into its hashed form.
[I wrote another post explaining custom ecto types using another type as an example](https://sealas.at/blog/2017-11/custom-ecto-types/), so I will only add an abbreviated version here.

## Custom password ecto type

The base for our custom type will be a string, since we're going to save the hash as a string to the database.
This makes the whole procedure very simple, as we're going to base our type on the string ecto type.

```elixir
defmodule SealasSso.EctoHashedPasswordTest do
  use SealasSso.DataCase

  describe "casting custom ecto hashed password" do
    test "type", do: assert EctoHashedPassword.type == :string

    test "cast and verify" do
      assert {:ok, hash} = EctoHashedPassword.cast("test_password")

      assert EctoHashedPassword.checkpw("test_password", hash)
      assert !EctoHashedPassword.checkpw("wrong_password", hash)
    end
  end
end
```

Since we inherit most functionality from ecto's native type, we can focus on testing what we would add: the cast function hashing our input and an interface to the verification function of the hash of our choice.

```elixir
defmodule EctoHashedPassword do
  @behaviour Ecto.Type
  def type, do: :string

  @doc """
  Hash password with currenly used hashing algorithm
  """
  def cast(password) when is_binary(password), do: {:ok, Comeonin.Argon2.hashpwsalt(password)}
  def cast(_), do: :error

  def load(password) when is_binary(password), do: {:ok, password}
  def load(_), do: :error

  def dump(password) when is_binary(password), do: {:ok, password}
  def dump(_), do: :error

  @doc """
  Check password against hash with currently used hashing algorithm.
  """
  @spec checkpw(String.t, String.t) :: boolean
  def checkpw(password, hash), do: Comeonin.Argon2.checkpw(password, hash)
end
```

Since we use Argon2 we implement our type with that.
If at any point we want to change the hashing function to something else, we have it consolidated in one place where we can then simply exchange it.

Well, almost.

To ensure that we're not breaking anything, let's add a test verifying that even in case of a future hash change, our previously stored Argon2 hashes still get verified.
Given the hypothetical case that we panic because Argon2 has been completely broken, and we need to change our algorithm NOW, we secure ourselves against forgetting to include the ability to still accept old Argon2 hashes; even if we only output hashes with a different algorithm.
Aren't tests nifty little buggers?

```elixir
@argon2_hash "$argon2i$v=19$m=65536,t=6,p=1$79ljDB93b7A3W4LsbyoI2A$yiYBzrw1OaQiS86YESKTrwh8l9NnsUpbugddemKPv0w"

test "verify argon2 hash", do: assert EctoHashedPassword.checkpw("test_password", @argon2_hash)
```

## Authentication Controller

Now that we have our migration, schema and type done, we can move on to the controller part.

### Let's write some tests

to find out and define what we're going to expect our authentication to look and behave like.

```elixir
defmodule SealasSso.AuthControllerTest do
  use SealasSso.ConnCase

  alias SealasSso.Repo
  alias SealasSso.Accounts.User

  @create_attrs %{email: "some@email.com", password: "some password", active: true}
  @valid_login  %{email: "some@email.com", password: "some password"}
  @failed_login %{email: "some@email.com", password: "wrong password"}

  def fixture() do
    {:ok, user} = %User{}
      |> User.create_test_changeset(@create_attrs)
      |> Repo.insert()
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  defp create_user(_) do
    user = fixture()
    {:ok, user: user}
  end
end
```

You'll notice that our passwords are *very* simple.
The password's complexity-check happens on the frontend, in JavaScript.
The frontend in its finished state will never actually send a cleartext password to the backend to perform any such test on it.
This double hashing reduces the likelihood of a leak at any stage of the process.

With this in place, we can now set some test data and setup functions for creating users to test our access with.
Next we can go on and define our actual use cases.

What do we want a successful login to look like?

```elixir
  describe "login" do
    setup [:create_user]

    test "successful authentication as a user", %{conn: conn} do
      conn = get conn, auth_path(conn, :index), @create_attrs
      assert %{"auth" => auth_token} = json_response(conn, 201)

      assert {:ok, token} = AuthToken.decrypt_token(auth_token)

      {:ok, token_creatd_at} = DateTime.from_unix(token.fields["ct"])
      assert DateTime.diff(DateTime.utc_now(), token_creatd_at) >= 0

      conn = conn
      |> recycle()
      |> put_req_header("authorization", "bearer: " <> auth_token)
      |> get(user_path(conn, :index))

      assert json_response(conn, 200)
    end
  end
```

The most important part here is actually the first two lines of the test:

```elixir
conn = get conn, auth_path(conn, :index), @valid_login
assert %{"auth" => auth_token} = json_response(conn, 201)
```

Accessing the `auth_path` route should give us a 201 HTTP code response, which stands for "Resoure created".
That newly created resource is the token it gives us back, which we then use to authenticate further requests.
Then we go on to validate the token with a separate function, and finally go on and try to access a protected route with it.

All that's missing is covering failure states; failed authentication because of bad credentials, and refused access for a protected route.

```elixir
test "fail to authenticate with wrong password", %{conn: conn} do
  conn = get conn, auth_path(conn, :index), @failed_login
  assert json_response(conn, 401) == %{"error" => "auth fail"}
end

test "get 401 for protected route", %{conn: conn} do
  conn = get conn, user_path(conn, :index)

  assert json_response(conn, 401) == %{"error" => "auth fail"}
end
```

This covers our basic usage cases for a login, so:

### Let's implement it!

Knowing what our authentication controller is supposed to do, this is pretty straight forward:

```elixir
defmodule SealasSso.AuthController do
  use SealasSso, :controller

  alias SealasSso.Accounts.User
  alias SealasSso.Repo

  @spec index(Plug.Conn.t, %{email: String.t, password: String.t}) :: Plug.Conn.t
  def index(conn, %{"email" => email, "password" => password}) do
    user = User.first(email: email)

    cond do
      user && user.active && EctoHashedPassword.checkpw(password, user.password) ->
        conn
        |> put_status(:created) # http 201
        |> render("auth.json", %{auth: generate_token(user)})
      true ->
        conn
        |> put_status(:unauthorized) # http 401
        |> render("error.json")
  end
end
```

We only have two conditions here that will suffice our test cases: A successful login, and a catch-all `unauthorized` error.
If the user exists, is active and has a matching password we can go ahead and generate an authentication token.

## Working with Tokens

Our authtoken library is nice enough to prepare us some tokens, but we still have to handle them responsibly in our app.
Two checks are still missing for that: is the token timed out, and is the token stale and needs refreshing?

First, getting a timed out token

```elixir
conn = get conn, auth_path(conn, :index), @valid_login
assert %{"auth" => auth_token} = json_response(conn, 201)

{:ok, token} = AuthToken.decrypt_token(auth_token)
{:ok, auth_token} = AuthToken.generate_token %{token | "ct" => DateTime.utc_now() |> DateTime.to_unix() |> Kernel.-(864000)}
```

Requesting the token is analogous to the login.
Next we'll decrypt it, and inject a creation time way in the past so it's going to be timed out -- or at least we expect it to be!

```elixir
conn = conn
|> recycle()
|> put_req_header("authorization", "bearer: " <> auth_token)
|> get(user_path(conn, :index))

assert json_response(conn, 401) == %{"error" => "timeout"}
```

The process for creating tokens that need to be refreshed is exactly the same, we just replace `"rt"` (refresh time) with `"ct"` (creation time); and we'll test for another message:

```elixir
conn = conn
|> recycle()
|> put_req_header("authorization", "bearer: " <> stale_token)
|> get(user_path(conn, :index))

assert json_response(conn, 401) == %{"error" => "needs_refresh"}
```

But we're not done here, `needs_refresh` is after all a request to refresh the token to be able to continue working with the API.
So let's imagine how we'd go about getting a new token.

```elixir
conn = get conn, auth_path(conn, :index), %{token: stale_token}
assert %{"auth" => auth_token} = json_response(conn, 201)
```

And then let's retry the request expecting it to be successful this time.

```elixir
conn = conn
|> recycle()
|> put_req_header("authorization", "bearer: " <> auth_token)
|> get(user_path(conn, :index))

assert json_response(conn, 200)
```

The timeout and refresh answer should get handled by the library's router plug `verify_token`.
What is still missing is the refreshing of stale tokens, which given the easily accessible method \`refresh_token\`, also shouldn't be much of a problem:

```elixir
def index(conn, %{"token" => auth_token}) do
  {:ok, token} = AuthToken.decrypt_token(auth_token)

  case AuthToken.refresh_token(auth_token) do
    {:ok, token} ->
      conn
      |> put_status(:created)
      |> render("auth.json", %{auth: token})
    _ ->
      conn
      |> put_status(:unauthorized)
      |> render("error.json")
  end
end
```

Right on! Either send back a new token, or if it's any error we can just send back a nondescript error.

### Ah, but that is not all!

Refreshing tokens has one actually useful purpose: allowing you to check back with the backend in a longer interval to see if the user is still active, has the correct permissions or even still exists.
So what we have is a good starting point, but needs extending.

The test cases for refreshments need an additional one to ensure that if the user is not valid anymore, we don't get a new access token.

```elixir
test "refuse refreshing of token if user has been deleted or deactivated", %{conn: conn} do
  user = User.first(email: @valid_login.email)

  stale_token = create_stale_token(user)

  User.update(user, active: false)

  conn = get conn, auth_path(conn, :index), %{token: stale_token}
  assert json_response(conn, 401)

  User.delete(user)

  conn = get conn, auth_path(conn, :index), %{token: stale_token}
  assert json_response(conn, 401)
end
```

Hidden here within `create_stale_token/1`  is the same method to acquire a stale token as above; other than that, we get the user and `assert` getting a 401 if the user is either inactive or deleted.

On the implementation side of things we just need to add the same checks we already use for the normal login process.

```elixir
def index(conn, %{"token" => auth_token}) do
  {:ok, token} = AuthToken.decrypt_token(auth_token)

  user = User.first(id: token["id"])

  {:ok, token} = AuthToken.refresh_token(auth_token)

  cond do
    user && user.active && token ->
      conn
      |> put_status(:created)
      |> render("auth.json", %{auth: token})
    true ->
      conn
      |> put_status(:unauthorized)
      |> render("error.json")
  end
end
```

This is also where you could implement more advanced security checks, like following a user's IP, device, behaviour, etc.
Implementing such heuristics always comes with certain privacy implications that you need to keep in mind, finding a balance between the ability to track a user for the sake of security, and keeping a user's choices of access anonymous.
Keeping in tune with that, I'll just announce another article about this topic.

That's it for now! Next time we'll tackle verification by email, so stay tuned.
