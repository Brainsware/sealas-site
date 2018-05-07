---
title: "Offline first, client-side encryption and the quest for a proper datastore"
date: 2018-05-07
---

Permanent storage is something *most* applications want to have in one way or another. Selecting the right storage wouldn't be a choice at all if there weren't so many options out there, and a lot of these come with their respective advantages and disadvantages.

The process in principle is always going to be the same:

1. Figure out what we need, in a technical and a user experience sense
2. Figure out which options could fit our design
3. Compare these two sets and select accordingly

So the first step in figuring out what the correct storage option for our application is, is figuring out what our application is. Without knowing what our application is going to need, we can't make an informed decision about which path to take.

## Requirements

[Sealas](https://sealas.at) is at the stage where this question becomes relevant, and so we'll take it as an example. The user database is already done, and is using a simple single schema Postgres database. The application data is where it gets interesting.

We have two unique properties of our application we need to take into consideration:

* All our application data is being encrypted on the client before it reaches storage
* We want to have an Offline First application

### Client-side encryption

One of our goals is to provide a privacy focused application, so our users don't need to worry about any side effects of using a web application. This would include possible leaks, possible surveillance or any other data aggregation methods.

Storage wise this means all incoming data is opaque. We can't manipulate it and we can't look at it. Another thing we can't do, is forget that we have other goals as well: the biggest of them is a good user experience. One of the most recognizable aspects of a good user experience is speed, so one of the trade-offs necessary here is with metadata.

Just because we don't want to look at the actual contents, doesn't mean we can't employ the help of relational data to make searching and selective access easier. Without any meta data, the only available method for searching left would be to always download all data on the client, which would have a significant performance impact.

### Offline First

Offline First may seem like a buzzword just thrown around to make us feel good.

Without a closer look at what we actually mean to do with it, this remains true. Again, this is not purely a technical feature, but one that is very much focused on our user experience design. In principle it just means we want to save all data locally before pushing it into some kind of messaging queue to sync it back to the server.

So what do we want to achieve by adding this capability?

There are two aspects that are most relevant here: keeping our data in sync when the connection becomes flaky, and providing us with the option for an amazing onboarding experience. Let's have a closer look:

\#### Connections

Flaky connections are not only an issue with a moody router or a roommate who all of a sudden decides to download the entire internet. If at any point we want to expand our web application to serve mobile users as well, we reach an entirely different realm of constantly dropping connections. Having a working data sync ready however allows us to keep working with the same code base.

With a growing set of options to implement mobile apps with JavaScript like [NativeScript](https://www.nativescript.org) for Angular and [Vue.JS](https://nativescript-vue.org), or [React Native](https://facebook.github.io/react-native/), this is something to keep in mind.

User experience wise this also enables something crucial: saving user input across sessions. So even if the browser decides to crash in just the right moment, all work done remains in the browser. Nothing ruins a day more than finding out the hard way that your app doesn't do automated backups of your work.

\#### Onboarding

One of the things I want to build and would love to see more often is a seamless transition between demoing a product and actively working with it. Offline First in this case enables us to give the user a clean new working environment to try out the application with their *actual* data and use-cases, and if they happen to like it, they can create an account to which we can sync the existing data.

## Datastore options

Now that we know what we're dealing with, let's look at the available options.

### Postgres with a multi tenant setup

Since Sealas' backend runs with Elixir and Phoenix, whose default supported database is Postgres, this would be the most natural choice when going for a RDBMS. We didn't rule out relational data after all, so it makes sense to include it as a viable option.

Other advantages of using Postgres:

* Very stable and mature product
* Big community and support base around it
* Rich "NoSQL" data support with HStore and JSON support

Schematic scalability is not that much of an issue for us, since at least the bulk of our data is going to a simple blob whose structure would be changed client-side anyway.

### Postgres with a multi instance setup

Same argumentation as above with one key difference: every user would get their own database. Having a multi instance setup allows us to completely separate data at a user level. This would allow us to easily add features for each individual user with their own structure. We could also include stricter ACLs for added security.

Our users' data is encrypted though, so it's not that much of a concern as it would be otherwise. Apart from that, the setup and maintenance is also a bit more complicated, especially with updates, since every database would need to have their migrations run separately.

### CouchDB (+ PouchDB)

[PouchDB ](https://pouchdb.com)is the ready-made solution for Offline First support that an implementation with Postgres would be lacking. It provides you with a database on the browser, which syncs back to a CouchDB instance.

In CouchDB terms, a connection between two databases is a sync — but at the same time it can also be unidirectional to serve as a backup. On the server-side this would make backups absolutely trivial.

PouchDB even sports backwards compatibility for almost any more modern browser. One of the things that worries me about this option though, is that it's a very niche project that doesn't have a lot of traction.

## Decisions, decisions

CouchDB may seem like the ideal candidate, when focusing only on the sync aspect. But then again there's no such thing as free lunch and every good thing also has its downsides. The easiest one to point out is that it would make for a heavier tech stack.

Couch also wants to be your application server, which is even more true in combination with Pouch, as it wants to speak directly to the database. So if you already have an authentication system in place, this might become a pain to integrate.

Postgres on the other hand doesn't have a widespread solution for Offline First support ready-made to just plug in and play. There is however one new addition to the world of web development that is getting more and more mature: Service Workers; background scripts that act as proxies between your app and the server, which can access the IndexedDB API for caching.

Another big plus for a stack with Postgres, is my own level of experience with running applications backed by an RDBMS. Experience building things usually results in more robust code but especially something that gets done way quicker. Then again, you lose out on learning something new.

In the end pondering only gets you so far, and the one thing that will get things done the easiest is tossing a coin or experimenting with a few prototypes. We would need to find out how easily possible it is to integrate Pouch+Couch into an existing application design and how easy it is to make changes to the way data is saved and partitioned. If that proves too much work, Postgres wins again.
