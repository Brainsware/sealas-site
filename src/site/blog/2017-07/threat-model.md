---
draft: false
title: "Sealas Threat Model"
date: 2017-07-10
---

Before we can properly develop our application, it helps to have a clearly formulated idea about what you want to do, and why.
When it comes to an application whose goal is to provide a secure environment for its users, it is important to have a concrete threat model.
This way we know what to protect against - and also why.

There are three different areas around which our threat model is built: The infrastructure, the application and the interaction design.

## Idea

The core idea behind our threat model, the one which initiated the whole project, is that the main vulnerability and threat to protect against is the vendor.
The SaaS vendor who stores all of your application data on some infrastructure, mostly all in cleartext.
On the other hand, we also want to protect the side of the vendor.
A technical solution to the question of how to handle sensitive data is easier to uphold than a contractual one.

You can read more about our motivation to build Zero Knowledge applications [here](/blog/2017-02/why-we-develop-zero-knowledge-software).

So why put distrust on the side of the vendor? There are always a few unknown factors which can lead to leaked, stolen, sold or compromised data.
The vendor might be incompetent - or to put it more lightly: as long as it is a human driven entity, inherently prone to accidents (I wonder when [the first purely AI driven company][6] will be a thing).
They might be compromised, either by a malicious third party attacker or by a government subpoena.

## Design

The other big topic with security is always design, specifically user interaction design.
If you want to have perfect application security, simply make your creation unusable; just like the perfect network security is a cut network cable.
On the other hand, if the application is decently usable but the security measures impose annoying hurdles, you will most likely just [decrease the security of the application][1].

The less effort a user has to put into keeping the account and the application secure the better.
The more incentive a user has to want to be secure and follow a secure path the better.
[An interface or a process should be designed to make it as hard as possible to make mistakes][2].
And more often than not, the element of human error lies on the side of the designer, not the user.
[The Design Of Everyday Things][3] is a mandatory read on this subject - as well as possibly any other subject.

## Application data

Now that we've established a the main vector of attack we want to protect the user from, we can define how we want to build the application, so that maximum security is achieved.
The following pieces of data are available from the user and will be generated in interaction with the application:

* Authentication tokens
* Bulk data
* Index data
* Customer data

With the exception of customer data, all of these need to be stored encrypted, so the vendor is at a minimum level of risk or temptation to extract information.
If properly implemented the vendor's service is limited to storage and maintenance, without any knowledge about the details of the user's activities, except of course about the level of activity.
This will ensure that the only possibility to share access to information stored and managed through the application is by an explicit action.

### Authentication tokens

First and foremost are the means to gain authenticated access which need protection.
There is no use in storing all data encrypted when the token to gain access is freely available.
Our goal here is to ensure that the vendor at no point has the possibility to know the access tokens.

For account access we need a passtoken (password/phrase), or some other kind of permanent identification secret that only the user has access to.
This can't be a fingerprint, or a face — [because they aren't secret][5].
But it could be a physical key or any other kind of object that is unique to the user.
However, until those are reliable and accessible enough, we will stick to passtokens.
Before being sent to the server it will be [hashed][4] on the client, before also being hashed on the server.
That way the cleartext passtoken is never known to the vendor, even if it would only be available temporarily in memory.

### Customer business/Bulk data

Any data containing information about the application state - anything that a user works on or with within the application - can be classified as customer business data — analogous to business data.
Since to our application it's completely opaque, we'll just consider it "bulk data".
Since we don't want to manipulate or search this set of data, we can store this as a blob in our datastore.

To enable the encryption of data, we need to generate a key.
The key should be independent from the password, for two reasons: Using a password as key will always be weaker than a fully randomly generated key.
An independent key also enables the user to change the password freely and share the access key, should they choose to do so.
With the access token generation being independent, the user can then also create new keys, which could be inherently temporary or simply revoked at some point if necessary.

This must happen on the client side, without the vendor at any point knowing the access key.
That now just leaves the protection of the encryption key.
For that we can use the passtoken: Given that the vendor only ever sees the hashed version of the passtoken, we can use its cleartext version as the key for encrypting the bulk data key.

### Index data

Now that all application data is encrypted we get to the problem of performance tradeoffs, namely: searching data.
As of right now, we can only download all data to the client and search it locally, which can get pretty slow with larger datasets.

We can mitigate this at least partially, by saving sets of data for searching as extra hashes.
For example, invoices and payment get saved with a hash containing the year and a combination of year and month.
This would enable easier yearly or monthly reports.

To avoid any possibility to extract information about the value of the index, we can secure the hash with an extra key unique to the user as a salt.
The salt itself is stored encrypted alongside the application key.

### Customer data

Customer data is all data used for contacting your customers and for generating invoices.
Since this data needs to be freely accessible to your vendor, this cannot be encrypted.

Although there is one thought here for the future: you could allow for anonymous billing which would make it possible to forego any saving of personal contact information.
This would probably make it impossible to have it tax deductible though, so the usefulness is limited.

## Great Success!

This concludes the threat model for the application itself.
There is one more part missing, which we'll cover next week: the infrastructure.

[1]: https://www.schneier.com/blog/archives/2009/02/balancing_secur.html
[2]: https://www.schneier.com/blog/archives/2016/10/security_design.html
[3]: https://www.amazon.com/Design-Everyday-Things-Revised-Expanded/dp/0465050654/ref=pd_lpo_sbs_14_t_0?_encoding=UTF8&psc=1&refRID=1QCP270GQSGYEEPW4F8B
[4]: https://simple.wikipedia.org/wiki/Cryptographic_hash_function
[5]: http://www.zeit.de/digital/datenschutz/2014-12/fingerabdruck-merkel-leyen-hack-ccc-31c3/komplettansicht
[6]: https://qntm.org/computers
