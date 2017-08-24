---
title: Setting up a Phoenix Umbrella App
date: 2017-08-24
---

Our decision to run the rewrite of Sealas with [Elixir](https://elixir-lang.org) came out of our interest in the language and the architecture behind it.

Elixir is a (more) readable Erlang, which builds upon OTP, which makes it highly suitable for any distributed system or networked system in general. Failure states are an integral part of the system, which means that if any critical error or exception occurs the process just [crashes](http://wiki.c2.com/?LetItCrash) - or shuts down - and restarts. It's [piping operator](https://elixir-lang.org/getting-started/enumerables-and-streams.html#the-pipe-operator) is sexy as hell and makes the functional programming aspect a lot more palatable.

All in all Elixir is sexy enough that we want to give it a try as the base for our project.

The main existing framework for web applications for Elixir is [Phoenix](http://phoenixframework.org), which is what we're going to use to build the backend.

## Architecture

Phoenix 1.3 introduced a new way to structure projects: umbrella apps. With the umbrella structure you can split a project into various smaller applications all running from the same project space. Comparable to separating access to your projects via VHosts, each app under an umbrella project is running under a different port, yet retain their capability to share code and functionality through their respective namespaces.

This, while providing lots of awesome opportunities to separate distinct parts of your application, also increases complexity. That of course makes it a big deciding factor in whether this makes sense for your project at all: is it big enough to allow for sensible splitting without succumbing to the problem of an over engineered mess?

Since we already built Sealas once we have a pretty decent idea of its scope and of which parts are necessary and going to be built:

### SSO

The SSO or authentication app keeps all code and interaction for the user database. Here we'll have the registration, authorization and authentication, and access recovery processes. Writing this as a separate app also makes it easier to re-use it for other projects with similar requirements for its user data handling.

Mailing was previously also handled here, but could easily be split away into another separate app.

### API

All interaction with the permanent datastore goes through this part, as well as some access to authentication mechanisms. Authentication is the first and only part so far that requires cross-app access to code.

### Frontend

The main part of the application and the one that relies the least on the backend, as it's mostly static content. All of the javascript base goes here, along with the generators and CSS files.

This one could easily be replaced by a Node.js or Apache server, but since it's easier to handle deployment and server infrastructure from one place, we're going to keep it here.

## Building the umbrella

```
mix phx.new sealas --umbrella
```

This is the generator script for Phoenix umbrella projects, which is very similar to the native generator, with the addition of some dependencies and the directory structure for Phoenix apps.

The generated directory structure looks like this:

```
| sealas
| > apps
| > > sealas
| > > sealas_web
| > config
```

The separation of apps by default is in a backend app, handling all business logic and connection to a datastore, and a frontend app, handling all views and templates. Since our main application doesn't rely on any backend, we're not going to use this one for now. We do however need to add at least two applications to our project: sealas_api and sealas_sso.

First we need to switch to the apps directory, then generate our new apps:

```
cd apps/
mix phx.new sealas_api
mix phx.new sealas_sso
```

With `mix phx.new` we generate a new Phoenix 1.3 app - `mix phoenix.new` is the generator for version up to 1.2.

### Configuration

Each of the apps has its own separate config files found in `APP_NAME/config`, which is also where you set the ports.

```
config :sealas_web, SealasWeb.Endpoint,
  http: [port: 4000],
```

`sealas_web` being our main entry point gets the default port, while the others get increasing port numbers assigned to them.

Each app also defines their respective dependencies in `APP_NAME/mix.exs`. So until I am convinced of the advantages of further splitting the project apart, `sealas_api` and `sealas_sso` will handle the storage directly, which makes it necessary to add Ecto to the list of dependencies.

That's it for the basic setup for Sealas as an umbrella project! You can follow the development of Sealas here on [Github](https://github.com/Brainsware/sealas)
