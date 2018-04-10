---
title: "Designing a user system for an encrypted application (Auth Part 0)"
date: 2018-04-06
---

When writing a user system for a client-side encrypted application, you first have to start with the universe. Well, that might be too much, so let's start a bit further ahead.

The user system is usually the first big stumbling block when venturing into the development of a client-side encrypted application. Let's look at a regular application first:

## What's in a user system?

There's two main concerns covered in any user system:

* Authentication, checking the authenticity of a user's provided credentials and
* Authorization, checking if the user has sufficient rights to perform the requested action

Authorization, while usually messy and complicated in its own right, doesn't really differ for client-side encrypted applications; so we're going to focus on authentication.

The two basic, core elements of any authentication request is an **identifier** and an **authentication token/proof of identity**. Successfully combining those two elements let's you know **who** it is that wants to use your application, and that they really are who they claim to be. Or at least someone who knows how to identify as such.

Traditionally the token was only provided in the form of a password. With time the variations grew in number, adding new layers of security and complexity, some with the goal of reducing the complexity on the user's end.

* Third party services, that simply provide you with an opaque token so the user can reuse their account over and over again
* Password-less style of login, where the token is the link sent to the user's email account
* Two-factor authentication splits the concept further, by requiring a combination of knowledge and physical entity, like a password and a physical key like a Yubikey

Then there are other elements that are all essential when it comes to any authentication system that users intuitively expect to be there:

* Access recovery, in case you lost the post-it with your password on it. Usually you simply get sent a password reset link or token sent to your provided e-mail address. Simple and sufficient.
* Access token change, in case you are forced by the provider or administrator to change your password, for example because of a [password expiration policy](https://arstechnica.com/information-technology/2016/08/frequent-password-changes-are-the-enemy-of-security-ftc-technologist-says/) or a breach. Because nobody ever does it voluntarily.

These are all things we can make use of to design a regular user system. However, since we're not developing a regular application, but one to make our lives as developers more difficult, there's special considerations we have to take into account.

### So, what's in a client-side encrypted application's user system?

Well, let's back off a bit again, and start with a more elementary question:

*What are the important things to consider when developing an application for which you store data that is entirely opaque?*

There is no method for reading, no method for manipulating (other than destroying), no method for aggregating and analyzing data. This is the basis on which any application operates that encrypts all user data on the client before it is sent anywhere for storage. Following our [threat model](https://sealas.at/blog/2017-07/sealas-threat-model/), this is what we have to ensure to fulfil our own requirements.

Yet we still want to provide our users with a comfortable user experience. One of the most important factors in any web application is reliability. Nobody wants to use something that could break at any moment or is so fragile that one mistake from the user's side renders the whole experience unusable.

So how do we go about designing a user system that ensures resilience, usability and reliability with client-side encryption? We will look at the handling of the encryption key, how that ties in with account sharing, and various recoverability options in case of another password lost forever in the black hole behind a couch.

### Architecture/Design requirements

How does this thing even look like? What are the moving parts in this system?

First, to ensure that this is actually a client-side encrypted application, the client needs to be the only party ever having access to cleartext data. The server is more of a reduced dumb storage service. Moreover, the server is at no point not to be *trusted* with our cleartext data. Consider it a dubious henchman.

So all key generation needs to happen on the client, otherwise all our work would be useless. This leads us to our first additional data point for our user system:

## The application key

This piece of data is essential for the user, but how it is generated and which technique is more or less useful for which use-case, is a subject for a later article. We're going to look at two approaches of dealing with *storing* the key:

For the simplest variant we could forego storage altogether, by simply generating a key based on the user's password.

### The easy way

This is what I would consider a bad idea.

Looking at the lovely [Standard Notes app](https://standardnotes.org), an encrypted note taking app, this note on the registration page made me pause:

![Standard Notes registration screen](https://cdn.sealas.at/blog/sn.png)

No password reset for any kind of account system is a problem, but it's an even bigger problem when you have an application focused on security. Especially considering that passwords chosen by people are usually either [not good](https://www.csoonline.com/article/3244004/security/top-25-worst-most-insecure-passwords-used-in-2017.html), or [easily forgotten](https://www.schneier.com/blog/archives/2017/10/changes_in_pass.html).

This can be alleviated by some good UI/UX design on the registration page. For example you could provide automatically generated passwords for safekeeping in password managers. Helpful tips on how to choose a secure password is another one.

None of these however will make up for the fact, that your key and password are always interlocked. The result would either be an application without any password changing option, or one which would require re-encrypting all data once the password is changed.

### The hard way: decoupling login and account information

It's not really hard, just a bit more roundabout. Since generating the key every time based on the user's password is bad, we have to find some other way to handle the key. The approach I suggest is generating a random (as random as possible) key, and encrypt that using the user's password.

This way you have a clear separation of key and package, the encrypted container holding the key. The user can easily change the password, as now this operation means extracting the key with the old password, and repackaging it with the new one.

Another possibility open to us now is account sharing. Since the key is a separate entity, we can package our key up with a temporary password for someone else, who can then take the key and repackage that. Now both have access to the account with a shared key. Otherwise the only way to share an account would be sharing your password, which is always a big security risk. More important for the user however is the user experience element: as soon as you don't want to share your account anymore, you have to change your password. With separated access, you can simply revoke it.

## Recoverability

A lost account makes a sad user, and if with the account they also lost all their data, you will have a user that will probably hate you forever. This is especially true now that we have an encryption key that is encrypted using the user's password: that means we, or you, as the provider, can't just change the user's password and all is well. The encryption key requires the correct password.

Looking at it from a more positive side, having a packed up key opens up the way to more recoverability options we can implement to postpone a user's account's demise.

### Password backups

Since we store the password protected app key, one option is to save the previous packed key on a password change. Assuming there's been a new password leak and people actually follow their new year's resolution to change their passwords, chances are they're going to forget that new password. Having a "revert to previous password" option would be quite helpful here.

As the narrative already reveals though, user comfort is at odds with security. There are further steps we can make to alleviate some of the security downsides, like only providing access to this functionality through an e-mail link. For a more advanced version, you might track and check the user's behaviour or location to see if it is actually the user and not someone else trying to "recover" the account.

In case the user has a password manager, this is less relevant, so an option for the user to disable it might make sense.

### Recovery tokens on trusted computers

Another possibility opened up by a separated key and packaging is an extended version of "trust this computer". When logging in on a trusted computer, the client can generate a one-time use password for local storage on the computer with which the key gets packaged again. This is similar to a key sharing scenario, only that you are sharing the key with yourself and with a password that you don't know, and that is only usable once.

Again some security concerns about misuse arise; so additional barriers to access are really useful, like a link sent to the registered e-mail address.

### Restrictions

These examples also highlight the importance of one element, and a restriction on working with client-side encryption: [e-mail](https://sealas.at/blog/2018-03/translated-e-mails-and-account-verification-with-phoenix-and-swoosh-auth-part-4/) is an integral piece of communication and layer of security.

Third party authentication services are not something you can use here. The user will always have to provide you, or at least the client, with a password, thus rendering the advantages of a third party authentication void.

### Password-less login

Let's not fret, there's one more thing we can add, courtesy of our previously described recovery tokens: a password-less login. Any time a user wants to login on a system that is already identified to be "trusted", a separate password-less login can be added.

This would just send out an e-mail with a login link, that would use up the packaged key with the locally stored one-time password, use it for a login and then regenerate it.

## Recap

In contrast to a user system for a regular application, including client-side encryption of all data puts up some restrictions and additional data points that need to be considered. The most important one is the addition of an encryption key. Handling it can be done two ways: either generated every time on the fly using the password, or stored in an encrypted container using the password.

Generating it on the fly is quick and simple but also very restrictive, as it doesn't allow you to ever change your password.

Having a separate package for the key requires some additional code and interaction flows, but allows you to change the password any time you want. Coming with that are a myriad of recovery and UX options that become available.
