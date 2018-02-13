---
title: "Fortifying APIs: timing attacks"
date: 2018-02-13
---

One of the most important features of an API, besides usability, is resilience.
A big aspect of a more resilient API is a restricted amount of information communicated.
This is important to keep in mind, since every *bit* of information you give away, aids in an attack against your API.

A potential attacker will use any bit of information available; for example, the name of the software used in the backend, the specific version of your server or application software, or even the time it takes to resolve a request to a login or registration process.
This can tell you whether a user has been found, whether the password check has been done, etc.
since all of these take up different amounts of time.

You could try and add things like fake password checks even when no user has been found, or other mock processes, but I would say the simplest solution to this problem is to delay all requests to your user/authentication system to a set amount of time.
The exact duration would be up to the specific API, keeping in mind that it is longer than any kind of request handling would take, but is still barely [noticeable](https://www.nngroup.com/articles/website-response-times/) for the user.

In this case I have set it to 200ms, which is more than enough time for any checks, yet is still fast enough for a response from an API.
To make this kind of delay even less of an issue, make sure that the frontend provides instantaneous action feedback.
Depending on the kind of action, overall design and delay you could even provide some kind of [progress indicator](https://www.nngroup.com/articles/website-response-times/) or [skeleton screen](https://www.lukew.com/ff/entry.asp?1797).

## Implementation in Elixir

Let's go over an example implementation that is currently in use in [Sealas](https://github.com/Brainsware/sealas).
We can add a test for this in our authentication test suite:

```elixir
@minimum_request_time 200_000

describe "sso timing" do
  test "minimum request time", %{conn: conn} do
    time = Time.utc_now()

    get conn, auth_path(conn, :index), @failed_login

    diff = Time.diff(Time.utc_now(), time, :microsecond)
    assert diff >= @minimum_request_time
  end
end
```

Any request to the authentication route needs to take at least `@minimum_request_time` amount of time in ms.

In the router we can then add a [plug](https://hexdocs.pm/plug/Plug.Builder.html) to handle our needed time delay:

```elixir
@minimum_request_time 200_000

pipeline :delayed_request do
  plug :request_timer, @minimum_request_time
end

@spec request_timer(Plug.Conn.t, integer) :: Plug.Conn.t
def request_timer(conn, minimum_request_time \\ 200_000) do
  time = Time.utc_now()

  Conn.register_before_send(conn, fn conn ->
    diff = Time.diff(Time.utc_now(), time, :microsecond)

    if diff < minimum_request_time, do: :timer.sleep round((minimum_request_time - diff)/1000)
    conn
  end)
end
```

We're trying to determine the time it takes to handle the request up to the point of sending back an answer to the client.
`Plug.Conn.register_before_send` allows us to do exactly that: register a function that will execute before sending the result to the client.
In our registered function we check for the time difference between when the function has been registered and before it is being executed and `sleeps` for the difference.

For this to work we plug in our plug into our desired routes.

```elixir
scope "/", SealasSso do  
  pipe_through :delayed_request
  pipe_through :api

  get  "/auth", AuthController, :index
end
```

And we're done.
With this all requests to our user API will take about the same time, except for some fluctuation in factors you can't really influence, like latency.
This can now be easily applied to wherever we see fit.

There's more to come on this topic, but until then, keep safe!
