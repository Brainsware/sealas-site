---
title: "Securing Infrastructure"
date: 2017-07-21
draft: false
---

Last week we talked about the [application's threat model](/blog/2017-07/sealas-threat-model/).
Now let's talk about securing our infrastructure.

In general our infrastructure philosophy starts with: The network is hostile.
This includes our (cloud) providers.
Customer data needs to be readable to us so we know who to bill and how much.
This data still needs to be protected.
The technical conclusion to this is that we cannot send data in the clear between any of our services.
If we consider (filesystem) storage, databases, and backups to be services, it simply means we cannot store data in the clear, period.

## The Fallacies Of Distributed Computing

As far as the network is concerned, we can begin by looking at the classic [The Eight Fallacies of Distributed Computing](https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing)

- The network is reliable.
- Latency is zero.
- Bandwidth is infinite.
- The network is secure.
- Topology doesn't change.
- There is one administrator.
- Transport cost is zero.
- The network is homogeneous.

As far as our application is concerned, the first four points are the most interesting to us.
Especially as it pertains to the application's security.

The other issues are not very relevant to us: because we operate on too high a level, we hardly notice anything about Topology.

And since we are _native_ to the cloud, we are aware that the network is not homogeneous.
We're also aware that of transport cost.
But the data we're exchanging (Javascript to the browser, and encrypted blobs to and from the application) are so small, that we can neglect this, too.

So let's look at the things that *do* affect us.

## The network is reliable, latency is zero

Based on several [informal surveys of real-world communications failures](http://queue.acm.org/detail.cfm?id=2655736), we know that the network is *not* reliable.
However, before we can attempt to shield against these vulnerabilities, we have to consider what kind of availability our application is supposed to offer.

Apart from the initial load, communication with an API is the only part vulnerable to a volatile network in a web application.
Thus we can set our primary goal to have an "offline-first" experience.
That means, the application — once loaded — should work, regardless of connectivity.

For such an experience, we are evaluating databases that can keep data offline in the browser, and sync with the service provider as soon as there's (an acceptable) connectivity.

## Bandwidth is infinite

Our company's 8 year old billing data is currently about 2MiB in size.
From this point of view, at least after an initial sync, the bandwidth *is* practically infinite.

## The network is secure

The first layer of protection between the browser running the app, and the server delivering it is TLS.
HTTPS — more so than any other TLS based protocol, has made giant leaps ahead when it comes to setting and improving security standards.
The primary goal of all these measures is to make Man-in-the-middle-attacks close to impossible, and thus increase the trust in the authenticity of the programs and data.

[Qualys' SSL Test](https://www.ssllabs.com/ssltest/analyze.html?d=sealas.at) is perhaps the first stop for verifying in how far we comply with these standards.
If you look at that page, you will notice a lot is missing.
There main reason for this is that a lot of these security measures are best served when DNSSec is in place, and unfortunately, this is not the case for any of the providers we're currently using.

While this area is still feels like a gaping hole in our security measures, at least it has a very clear road map.

Similar things can be said and done for the [HTTP headers](https://securityheaders.io/?q=sealas.at&hide=on&followRedirects=on) that browsers rely on, for validating which JavaScript can come from which domain, and what it's allowed to access.
In this case, the list is short, but the road-map is equally clear: Try not to fall into any of [OWASP's Top 10 issues](https://www.owasp.org/index.php/Top_10_2017-Top_10)

This blog post wouldn't be about infrastructure, however, if we didn't talk about automation! So what's better than looking at these reports once?
Having a robot look at them every day, and tell us when something changes! Fortunately, SSL-labs has [opened their API](https://www.ssllabs.com/projects/ssllabs-apis/index.html) to such use, which means that we'll be able to integrate it during builds, or as a final step in our deployment pipeline!

## There is one administrator.

Our application is primarily developed for (and in) the cloud.
"The Cloud" doesn't have just one administrator, and we cannot trust any of them.
This means for us that we cannot trust clear-text connections between any of our services.

Since *storage* is a *service*, this first and foremost means that we cannot store anything unencrypted.
One of the most crucial data — our customers's names, addresses, and emails need to be readable to *us*.
This is our only vulnerable set of data, and must be protected from leaks.
So for us, it's clear that we cannot store this data unencrypted anywhere.
Not trusting our providers also means that our databases must use TLS when syncing.
It means that our backups must be encrypted and must be sent (and restored) via TLS.
Our preferred backup provider for this is [tarsnap](https://www.tarsnap.com).
And it means that we need to talk TLS to our CDN and SSO.

What makes this tricky is that many of these technologies will not have the same kinds of standards we discussed above with regards to preventing MITM attacks.
But, as [Let's Encrypt](https://letsencrypt.org) has shown, agility can go a long way towards providing a resilient security:

Being able to quickly (and automatically) rotate credentials — including (very short-lived) certificates, makes this possible.
[Vault](https://www.vaultproject.io/) for instance, is a technological solution to exactly this problem which we will closely examine as a core component of our architecture.

Having now so successfully secured our infrastructure, next week we'll look at the final component: The code.
