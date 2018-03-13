---
title: "Translated E-Mails and Account Verification with Phoenix and Swoosh (Auth Part 4)"
date: 2018-03-13
---

We're really starting to get to know each other, hm? Having gone through writing an auth token library in parts [1](/blog/2017-12/tokens-cookies-and-sessions-an-auth-story-part-1/) and [2](/blog/2018-01/encrypted-auth-tokens-for-phoenix-auth-part-2/), and the first steps towards protecting our API with an auth process in part [3](/blog/2018-01/designing-and-writing-a-basic-authentication-api-with-phoenix-and-elixir-auth-part-3/).

With part 4 now, we're adding an old but proven technique in the world of technology: emails! This will lead us to choosing an e-mail library, integrating it with Phoenix templates and translating those with gettext.
Verification e-mails will also allow us to actually test the verification and implement it fully.

## Why even email verifications?

Email verifications start to seem like something that's done just because That's How It's Always Been, so why not look at the rationale behind it.

Securing access for an encrypted application is of utmost importance, as losing your password means losing access, and losing access means losing your data - forever and for good.
If it were trivial to recover your data without it, the encryption wouldn't be doing anything useful other than playing the role of a fancy door guard.
There are some recovery methods bound to the email, so ensuring that you entered the correct email address and ensuring that you have access to it is sensible.

Other use-cases are two-factor authentication over e-mail and password-less login systems where you just get a special short-lived login link per e-mail, like in [Medium](https://blog.medium.com/signing-in-to-medium-by-email-aacc21134fcd).
So in short, a verification process still makes sense and provides real value.

## Collecting resources

If we want to send out e-mails we can either implement our own library, [which why you would ever do that is beyond me](https://www.youtube.com/watch?v=4s9IjkMAmns), or choose an existing one, of which there are plenty! There's 3 big ones, that I've seen recommended mostly:

[Bamboo](https://github.com/thoughtbot/bamboo), [Swoosh](https://github.com/swoosh/swoosh), and [Mailman](https://github.com/mailman-elixir/mailman).

They are supposed to execute a very specific task, so naturally they are very similar, with bamboo and swoosh being almost the same.
They all support sending via SMTP - if you include the corresponding submodule - they all support HTML with Phoenix templates, and they all provide testable mail structures.
Choosing between similar libraries is always an annoying endeavour, so the criterion I decided to base my choice on was most activity lately: swoosh.

With that out of the way, our additions to `mix.exs` look like this:

```elixir
{:swoosh, "~> 0.13"},
{:phoenix_swoosh, "~> 0.2"},
{:gen_smtp, "~> 0.12"},
{:gettext, "~> 0.14"},
```

### Gettext

People have this thing, where they come from different countries and different cultures, and thus don't all stick to one single language or punctuation system or even date format.
Even if you think you only need one language *now*, if you change your mind later, you will curse yourself and the enormous amount of additional work you put upon yourself.
I speak from experience.

Just imagine having to go through a few hundred files replacing strings with calls to a translation library, moving all those already translated strings to an external database and no, you don't have an intern you can push this off to.
You have to do it.
It's no fun.

[Gettext](https://github.com/elixir-lang/gettext) is the default way to add localization to your Phoenix app, which is accessible via the `:gettext` package, which in turn provides a GNU gettext like API for you to use.

## Sending mail

Preparations done, now it's time for \~action\~more preparation.
The mail package still needs some setting up, otherwise it won't know how to send mails, from where to send them and which credentials to use.

In `config.exs` goes the definition for the mail adapter we want to use.
With our projects we usually use SMTP over our existing external mail infrastructure.

```elixir
config :sealas_sso, SealasSso.Mailer,
  adapter: Swoosh.Adapters.SMTP
```

For production there's already a `prod.secret.exs` in the config folder, but for this and some other cases it's useful to have one for the development environment.
Even then I want to save credentials for services that I might not want to push to a public or even private versioning system.
So to `dev.exs`  I add the line `import "config.secret.exs"` and then the corresponding file, with the the mail config.

```elixir
config :sealas_sso, SealasSso.Mailer,
  relay: "mail.server.com",
  username: "app@user.name",
  password: "Wicked Secure appPassPhrase",
  ssl: true
```

The test environment will need a separate config, as you probably don't want to send out e-mails with every test run.
Swoosh provides a test adapter for use here, so we're going to put that in our `test.exs`:

```elixir
config :sealas_sso, SealasSso.Mailer,
  adapter: Swoosh.Adapters.Test
```

Configuration done, setup not quite yet.
Mail composition and delivery are two separate components with Swoosh, and each app needs to define their own mail delivery module.
It's very short though:

```elixir
defmodule SealasSso.Mailer, do: use Swoosh.Mailer, otp_app: :sealas_sso
```

### Sending emails with Phoenix templates

Now we can finally get to sending our sweet, sweet mails.
Since our project is fully based on Phoenix, we can take advantage of the existing template framework to power the HTML version of our mails.
With that in mind, we're going to use `Phoenix.Swoosh` and declare the the view modules for the views and layout.

```elixir
defmodule SealasSso.MailView, do: use SealasSso, :view

defmodule SealasSso.LayoutView, do: use SealasSso, :view

defmodule SealasSso.UserMail do
  use Phoenix.Swoosh, view: SealasSso.MailView, layout: {SealasSso.LayoutView, :mail}
  import SealasSso.Gettext

end
```

Our `SealasSso.UserMail` module is now ready to contain our mails.
Looking at the [docs](https://hexdocs.pm/swoosh/Swoosh.Email.html#content), the general pattern for building them is always the same: create a new mail object and chain together the calls to add features and options.

```elixir
mail = new()
|> to("user@email.tld")
|> from({"Mailer", "mails@from.app"})
|> subject("Hey there")
|> render_body(:template_name)
```

Since we're going to have different mails sent from this part of our app, with the same set of header parameters but different bodies, we can extract this part and put it in a generalized `prepare/1` function.
In this case we always want to extract the recipient from a user object, as well as use the same sender, like "Sealas Support <support@sealas.at>".

In general I would say it is better UX design to provide a "From" email address that is actually in use.
A "no-reply@" address is just making the process of calling for support more obtuse; especially in case of service mails that are easier to understand if context is provided automatically by the reply function of every mail client.
It doesn't matter if the footer provides an explanation like

> This is an automatically generated email.
Please do not reply here.
If you need help write to other@email.address

Don't be obtuse, just use the email that is actually in use.
It rhymes so it must be true.

```elixir
defp prepare(user) do
  mail = new()
  |> to(user.email)
  |> from(Application.get_env(:sealas_sso, SealasSso.Mailer)[:from])
  |> assign(:app_uri,    Application.get_env(:sealas_web, SealasWeb.Endpoint)[:app_uri])
  |> assign(:static_uri, Application.get_env(:sealas_web, SealasWeb.Endpoint)[:static_uri])
end
```

The `assign/2` function allows us to transmit information for use in our email's content.
In this case we almost always want to include some links to the app or the website, so we can make those available for use out of the config files - and more importantly, make them easier to change by having them in a config file and not hard-coded directly in the templates.

### Account verification mail

Let's look at one example, the mail sent out to verify the email account.
Using the set up mail from the `prepare/1` function the only things missing are the subject and content.

```elixir
def verification(user) do
  prepare(user)
  |> subject(dgettext "mail", "verification_subject")
  |> render_body(:verification, user: user)
end
```

Well, that was easy.
Calling the function from `iex -S mix` shows us a working email generation process (shortened for clarity):

```elixir
iex|1 > SealasSso.UserMail.verification(%{email: "user@email.address", activation_code: "1234"})
%Swoosh.Email{
  assigns: %{
    app_uri: "http://app.sealas.local",
    layout: {SealasSso.LayoutView, "mail.text"},
    static_uri: "http://static.sealas.local",
    user: %{activation_code: "1234", email: "user@email.address"}
  },
  from: {"Sealas", "support@sealas.at"},
  subject: "Verify your Sealas account",
  text_body: "Just one more step before you can get started.
  Copy the code below in the verification box:\r\n1234\r\nOr use this to go directly to the verification:\r\nhttp://app.sealas.local/user/verification?u=1234\r\n\r\nAfter the verification you can set a password for your account and start using Sealas.\r\n--\r\n\r\nSealas - Secure Easy And Lovely Accounting Software\r\n\r\nhttps://sealas.at/\r\n",
}
```

The subject line here is just a replacement key to gettext, called here with `dgettext` which translates to "domain restricted gettext".
This in turn allows us to specify the domain, or more simply put the translation file, from which we want to get the translation; in this case `mail`  or `mail.po`.
The translations are all located in `apps/[app_name]/priv/gettext/[locale]/LC_MESSAGES/[domain].po`

Calling the function and sending an email with it is equally easy.
You get the built up mail structure, pipe it to your mailer module and call the delivery function `deliver/0`.

```elixir
SealasSso.UserMail.verification(%{email: user.email, activation_code: code_hash})
|> SealasSso.Mailer.deliver
```

At some point though it's going to be a pain to have to verify all emails by having them sent out and looked at.
If only there was an easier way...

### Testing mails!

Emails in applications being a thing that I write so automatized, it never occurred to me to have testable emails, so I didn't even try to do any TDD with it.
I also don't want to pretend to have done so here, so I'll include the tests after having done the implementation.

Now that we know how to do it though, and see that those tests are actually pretty sensible and usable and *really easy* to write, we can certainly use this pattern to build the tests for our mails first in the future.

Step 1: `import Swoosh.TestAssertions`

Step 2: ???

Step 3: `assert_email_sent UserMail.verification(mail_params)`

Luckily we can try and recreate the elusive second step in our three step program to profit.
In the first step we simply import the set of test assertions in the beginning of our module, which grants us access to `assert_email_sent`.
Then comes the part where we append that assertion to our test for trying to register as a new user.
There we take the returned activation code and used email address to confirm the email that has been sent out with the content we expect.

In full this looks like this:

```elixir
test "register as a new user", %{conn: conn} do
  conn = post conn, registration_path(conn, :create), user: @registration_attrs
  assert %{"activation_code" => activation_code} = json_response(conn, 201)

  mail_params = %{email: @registration_attrs.email, activation_code: activation_code}

  assert_email_sent SealasSso.UserMail.verification(mail_params)
end
```

### Mail templates

Finally let's look at the templating for mails.
First the layout files.
The naming scheme is `[name].[type].eex` which in our case translates to two files `mail.html.eex` and `mail.text.eex` .
Using both HTML and text layouts makes us send out multi-part emails, so people who don't like HTML mails can read your mails too.
The text version of your email is also usually used to generate the preview text in most email clients, which sometimes just contains a friendly but entirely useless message reading

> Click here to view our e-mail in all its HTML glory!

Providing a proper text version of your emails is not that hard most of the time, so just do it.
Back to the layouts; we defined the name of the layout file at the top of `SealasSso.UserMail`:

```elixir
use Phoenix.Swoosh, view: SealasSso.MailView, layout: {SealasSso.LayoutView, :mail}
```

The content of the layout files is best presented by example using the text version of the layout, simply because it has so little HTML-y clutter.

```
<%= render @view_module, @view_template, assigns %>

--
This is a service email signature
Sealas - Secure Easy And Lovely Accounting Software

https://sealas.at/
```

So, as you can see the only really important thing here is the place where you want to put the final template containing the actual content.
The templates for the separate mails have the same naming scheme, and are placed in `templates/mail/[name].[type].eex`.

```
<%= dgettext "mail", "verification_one_more_step" %>

<%= @app_uri %>/user/verification?u=<%= @user.activation_code %>
```

Templates already have gettext available by default, so we can access its functions just as we do outside.
Calls prefixed with `@` are to variables bound to the mail; `app_uri` is passed on by our `prepare/1` function and the `user` object directly in the call to `render_body`: `|> render_body(:verification, user: user)` .

Finally, here's the finished mail in all its HTML glory, delivered directly to my inbox - and maybe your's soon too!

![Verification Mail](/images/site/blog/2018-03/verifymail.png)

With this we're done having a basic functional infrastructure for sending out mails.

Next time we're going to finish this series on authentication with a discussion and deeper look at account creation and various backend storage strategies when you want to go for an offline first strategy.
