# CONTRIBUTING

This document roughly describes how you can contribute to our project.

## Contributing a quick-fixed

We encourage everyone who finds a spelling or wording-issue to submit a patch.
The easiest venue for that is probably Github's edit button!

## Contributing a new blog post

If you contributed a few Pull-Requests or Issues, you may want to write about the topic of these!
Here's a quick guide for how to write a new blog post:

* New posts go in `src/site/blog/<year-month>/title.md`
* Put images in `htdocs/images/site/blog/<year-month>/title.jpeg`
* Mark your post as `draft: true`, unless you're submitting it in separate pr
* One sentence per line to make edits in Git easier to follow

You can test your changes with:

```sh
yarn install
nodejs ./build-site.js prod
# use your favourite HTTP server to view htdocs/index.html
```
