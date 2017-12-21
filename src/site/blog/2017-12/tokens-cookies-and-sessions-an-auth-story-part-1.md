---
title: "Tokens, cookies and sessions: an auth story (Part 1)"
date: 2017-12-20
---

When deciding which way to go with communicating and storing authentication information, one can easily drift into a bad trip and start wondering how anything ever works.

Before you lead yourself into a confused stupor, driving to Las Vegas in a convertible with a suitcase full of ether, acid and all kinds of other drugs, gather your tools, requirements and goals.

This is not going to be a detailed portrayal of each existing technology, but more a display of how to think through the process of applying that knowledge.

## Our tools

Luckily we don't have to invent everything from scratch, so what are our basic tools to manage the state of any authenticated user?

There's a few of them, and each of the approaches has its trade-offs attached.

### Stateless tokens

These are tokens that are purely tracked by the client.
It's an object that's either cryptographically signed or encrypted, and contains identifiable information.

Being purely client-side, they have a few distinct disadvantages, which made a few people speak out very harshly [against using JSON Web Tokens (JWTs) as session replacements](http://cryto.net/\~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/).
All session storage inside the token would add to the total size of the token, which at some point could make it quite big.

There is no way way to individually revoke tokens from the server side, unless you go with some hybrid solution described below.

### Stateful tokens

We can simply enhance stateless tokens with a smaller database for revocations to remedy at least one of the downsides — if that is truly important to your use-case.

### Session cookies

The classic among state tracking.
It's a cookie with an ID referencing a session object stored on the server.

The advantages of this are pretty clear outright: no information but an opaque ID is transmitted, which leaves all handling of authentication, authorization and state data on the backend.
You can easily revoke individual sessions; plus you're always left with a constant and small footprint.

This remains an advantage until you have to manage multiple servers and services, in which case the complexity of managing your sessions increases dramatically.

## Goals we pursue, priorities we set

Now we know what's out there, but what do we actually need? What do we want?

Or let's start with: what are we building?

That's right, we are building an application that runs mostly on the client.
Server-side sessions are really useful for one thing: managing the state of your application on the server's side.

Running a client-side application has one very important implication in this aspect: we don't do any state management on the server.
Especially considering that one of our goals is to be [Offline First](http://alistapart.com/article/offline-first), everything a user does stays on the client until it is synced back to the server.

Everything we really need our session/token system to do is track two bits of information: are you authenticated?, and who are you authenticated as? Which can be expressed even simpler as either having an identification token for a certain user or not.

Furthermore, we want to achieve simplicity with our deployment process.
Having independent servers and services allows us to simply set up a new server when we need it and add it to the network - or remove it, if we don't need it anymore.
This is a lot easier if we don't need to worry about keeping the state of sessions synced among all services.
Adding a single service that checks the validity of the identity of users that can be accessed by all subservices is clearly the better choice here.

Out of this set of goals and priorities it is clear which path is the one that will benefit us the most: tokens!

## State of session management in Phoenix

Phoenix doesn't come equipped with any session or token handling out of the box, so we'll have to either include or build one of our own.

There's an implementation of [JOSE/JWT for Elixir](https://github.com/potatosalad/erlang-jose) we can use to implement our token handling, which removes the burden of implementing that standard from us - but still leaves us with a standard that is [huge and complicated](https://neilmadden.wordpress.com/2017/03/15/should-you-use-jwt-jose/) and full of [bats](https://lobste.rs/s/r4lv76/jwt_is_bad_standard_everyone_should_avoid#c_k91fsa).

So, with that in mind, we shall create our own token library, with blackjack and -- err, encryption.
Most token libraries only offer token signing, which is argued should be enough for most use-cases; after all why would you need more than just authenticity of your tokens?

One very important principle that comes into play here is: never give away more information than absolutely necessary.
Every bit of information is an additional potential attack vector.
Encrypting your token's payload alleviates that and helps you give away exactly as much information as you need when providing your users with something to authenicate with: *none*, except for the *existence* of the token.

### JWT Headers

Following the advice in [7 Best Practices for JSON Web Tokens](https://dev.to/neilmadden/7-best-practices-for-json-web-tokens), we can get rid of even more.

The only parties involved in the authentication process, who also need to be able to decrypt the tokens, are those who also have access to all the metadata.
So, we can safely remove the JWT headers, which not only makes our tokens safer, they also instantly become a lot lighter.

If at any point some third party should be included in the process, we can simply define one set of acceptable parameters and still not need any headers in our tokens.

## SealasTokens

I will release a corresponding library soon that will implement simple encrypted tokens for our authentication system, accompanied by a post explaining the details.

Until then, try and stay clean and away from bats.
