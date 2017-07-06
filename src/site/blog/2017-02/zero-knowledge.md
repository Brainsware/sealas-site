---
title: Why we develop Zero Knowledge Software
date: 2017-02-26
---

[Every](https://www.freshbooks.com) [cloud](https://debitoor.de) [service](https://www.xero.com) you may use implicitly requires you to trust them with **all** your data you work with.

This means that your service provider will always know everything you do when using their product, whether you agree to that or not.

<!-- more -->

The few exceptions in which almost all services offer encrypted storage are  password managers, which is perfectly understandable and necessary, and backup, which is weird, because data shouldn't only be important when it's not used and worked with.

Personally, I am very unhappy with that situation.
Software run in the cloud has many benefits I don't want to miss:
No maintenance, because you don't have to care about updates and all the hassle that goes with that.
Setup is mostly just creating a new account.
Access from everywhere and every device.
But the disadvantages of having your data stored in cleartext are becoming less and less acceptable for me.

Not because I have something to hide.

Not because I'm paranoid.

Because I choose not to share every single detail of my work or private life.
Because I want there to be a choice with vendors: Do I go with the one that offers a private solution or do I not care in this case and go with another one?

In the world of SaaS there are sadly no such options, forcing me to either use an internally installed and maintained version or - you know, drop my principles for this case and use it anyway, because it sucks slightly less than the alternative.

> **SaaS** stands for **Software as a Service**. Basically it's all software running in the cloud, which you access through your browser.

We started delving into the realm of SaaS a while ago, [Sealas](https://sealas.at) being our first service we launched.
It's an invoicing and accounting software for freelancers and small businesses, with the added bonus that all data is stored encrypted.

Having the freedom of choice when developing your own software, means you can adhere to your principles and values.

## Our SaaS Manifesto: Zero Knowledge

The concept of "Zero Knowledge" forms the core of our product development.
This is our **manifesto** for developing SaaS products.

### Zero Knowledge?

Zero Knowledge put simply means: we know nothing about what you do with our service.

It also means, we have no means of finding out what you are doing, other than asking you directly.
Everything you do on a Zero Knowledge system is encrypted before it is sent to the server, so you can make sure that your data isn't vulnerable at any point.
The key to the encryption is also never known to the vendor.

The last part is key here: your key to your data is itself encrypted on the client before it ever reaches the server.
This is done either with a password, passphrase or some physical token or a combination thereof.
This guarantees that you and only you have access to your data.

## The Core Values

I talked about what our principles and values are, and I think it's only fair to put forth a rationale for the details of them, if you are to get to know us better:

### Trust: You shouldn't have to blindly trust your vendors.

Trust is about relationships.
We just provide a service, which shouldn't require implicit trust in everything you do.

People shouldn't be inhibited from doing their desired work with a service because of possible monitoring.
Or the possibility of a leak, due to a hack or accident, which does happen occasionally.

### Usability: Encryption must not sacrifice usability.

Security sacrificing usability creates unreliable and unsafe systems.
The safest solution should only require minimal effort, while producing a maximum of security.

### Privacy: As long as you do not give consent, your data remains private.

You may be doing shopping lists, you may be writing your will.
You may be invoicing for construction work or your psychotherapy office.
Your data is only yours to access until you choose to share, by creating either a shared account or creating some other kind of access for third parties.

Gaining access to your data **without your consent**, is the same as stealing your keys and breaking into your filing cabinet.

### Control: Your data is yours, and should always be in your control.

It shouldn't make a difference whether your data is stored offline or with an online service, it is yours to control and do with as you wish.
