---
title: "Custom ecto types"
date: 2017-11-18
---

Custom types in Ecto are a really nice way of abstracting away some functionality you need in a lot of places concerning your schemas.
That sounds really nice, but let's break that down to something more digestible.

# Introduction / Why custom ecto types?

Assume you have a task where you need to transform data each time before saving it to your data store.
So, maybe you want to store a password and want to generate a cryptographic hash of the value, or you need a customized date format.
There's a few ways to do this:

You could write custom queries to your data store, but that would mean you would have to also write more code to stitch together your result set; you could manipulate your data every time before transferring it to your schema, but that would make it hard to track your transformations and scatter your code all over the place.

Custom types are basically getters and setters, and are thus the ideal place to put that kind of functionality.

So, let's examine one example case we've had in Sealas so far: transform any hashed string to a UUID to make it indexable on PostgreSQL.
This will also provide us with a reusable pattern for more cases like this.

# Testing and writing custom ecto types

Consulting the [documentation](https://hexdocs.pm/ecto/Ecto.Type.html) we see that we need 4 functions in our custom type:

* `type`
* `cast`
* `dump`
* `load`

We'll start out by writing a - failing - test case for what we want to achieve.
The most important one is the cast function, as this is where the actual conversion happens.

```elixir
    defmodule SealasApi.EctoHashIndexTest do
      use SealasApi.DataCase

      @test_invoice_uuid "c13bbe22-f8f6-55a0-47af-313e82edfbbd"

      describe "casting custom ecto hash type" do
        test "cast" do
          assert EctoHashIndex.cast("test_invoice") == {:ok, @test_invoice_uuid}
        end
      end
    end
```

Starting out with the basics, I define some test data here, a UUID to match against.
This you could get out of Postgres with the SQL query `SELECT md5('any_string_here')::uuid`.
With that test data at hand we can go for the first function.
Casts return a tuple with the structure {:ok, data}, so that's what we test for.

The other simple test is for the type.
We want the type to be a UUID:

```elixir
    test "type is uuid" do
      assert EctoHashIndex.type == Ecto.UUID
    end
```

These tests will fail of course, since we don't have the actual type implemented yet, so let's go ahead and implement it.

```elixir
    defmodule EctoHashIndex do
      @behaviour Ecto.Type
      def type, do: Ecto.UUID

      def cast(string) when is_binary(string) do
        Ecto.UUID.cast :crypto.hash(:md5, string)
      end
      def cast(uuid), do: Ecto.UUID.cast uuid
    end
```

With this we've got our basic necessities set up, the `behaviour` for `Ecto.Type`, the type `UUID` itself for the database, and a basic cast function.
The only thing I really want to do here is make every string passed to our `HashIndex` type converted to a UUID, so we convert it to an md5 hash first and then pass it on to the original UUID ecto type.

Everything works out and passes the tests, however passing UUIDs causes them to be transformed again, so I added a check for UUIDs being left alone.

```elixir
    test "cast uuid" do
      assert EctoHashIndex.cast(@test_invoice_uuid) == {:ok, @test_invoice_uuid}
    end
```

with the then corresponding implementation:

```elixir
    def cast(string) when is_binary(string) do
      case Regex.run(~r/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/, string) do
        nil -> Ecto.UUID.cast :crypto.hash(:md5, string)

        [_] -> {:ok, string}
      end
    end
```

UUIDs always follow the format 8-4-4-4-12 hexadecimal digits, so a simple regex should do the trick here.

The remaining two functions, `load` and  `dump` don't need any custom functionality, so we'll use Elixir's handy shorthand `defdelegate` to just call Ecto.Type.UUID's implementation of those.

```elixir
    defmodule SealasApi.EctoHashIndexTest do
      use SealasApi.DataCase

      @test_invoice_uuid "c13bbe22-f8f6-55a0-47af-313e82edfbbd"
      @test_invoice_uuid_binary <<193, 59, 190, 34, 248, 246, 85, 160, 71, 175, 49, 62, 130, 237, 251, 189>>

      describe "casting custom ecto hash type" do
        test "cast" do
          assert EctoHashIndex.cast("test_invoice") == {:ok, @test_invoice_uuid}
        end

        test "cast uuid" do
          assert EctoHashIndex.cast(@test_invoice_uuid) == {:ok, @test_invoice_uuid}
        end

        test "dump" do
          {:ok, hash} = EctoHashIndex.cast("test_invoice")

          assert EctoHashIndex.dump(hash) == {:ok, @test_invoice_uuid_binary}
        end

        test "load" do
          assert EctoHashIndex.load(@test_invoice_uuid_binary) == EctoHashIndex.cast("test_invoice")
        end
      end
    end

    defmodule EctoHashIndex do
      @behaviour Ecto.Type
      def type, do: Ecto.UUID

      def cast(string) when is_binary(string) do
        case Regex.run(~r/\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/, string) do
          nil -> Ecto.UUID.cast :crypto.hash(:md5, string)

          [_] -> {:ok, string}
        end
      end
      def cast(uuid), do: Ecto.UUID.cast uuid

      defdelegate load(data), to: Ecto.UUID
      defdelegate dump(data), to: Ecto.UUID
    end
```
