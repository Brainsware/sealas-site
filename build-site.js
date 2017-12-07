var debug = process.env.NODE_ENV === 'development';

if (process.argv[2] === 'dev') {
  debug = true;
} else if (process.argv[2] === 'prod') {
  debug = false;
}

var path       = require('path'),
 metalsmith    = require('metalsmith'),
 markdown      = require('metalsmith-markdown-sections'),
 drafts        = require('metalsmith-drafts'),
 excerpts      = require('metalsmith-better-excerpts'),
 define        = require('metalsmith-define'),
 ignore        = require('metalsmith-ignore'),
 multiLanguage = require('metalsmith-multi-language'),
 i18n          = require('metalsmith-i18n'),
 permalinks    = require('metalsmith-permalinks'),
 collections   = require('metalsmith-collections'),
 feed          = require('metalsmith-feed'),
 sitemap       = require('metalsmith-sitemap'),
 moment        = require('metalsmith-moment'),
 extlinks      = require('metalsmith-external-links'),
 layouts       = require('metalsmith-layouts'),
 domTransform  = require('metalsmith-dom-transform');

codeHighlight = function(options) {
  const highlight = require('highlight.js');

  return function highlightContent(root, data, metalsmith, done) {
   Array.from(root.querySelectorAll('code')).forEach(node => {
     highlight.highlightBlock(node);
   });

   done();
  };
}

 //static_uri = debug ? 'http://static.sealas.local' : 'https://static.sealas.at';
 static_uri = '';
 app_uri    = debug ? 'http://app.sealas.local' : 'https://app.sealas.at';
 site_uri   = debug ? 'http://sealas.local' : 'https://sealas.at';

 ignored_files = ['locales/*', '*.tpl', '*.json']
 if (!debug)
  ignored_files.push('drafts/');

 const DEFAULT_LOCALE = 'en';
 const LOCALES = ['de', 'en'];

metalsmith(__dirname)
  .metadata({
    'site': {
      url: site_uri,
      title: 'Sealas - Secure Easy And Lovely Accounting Software'
    }
  })
  .source('./src/site')
  .destination('./htdocs')
  .clean(true)
  .use(ignore(ignored_files))
  .use(drafts())
  .use(collections({
    'blog': {
      pattern: 'blog/**/*.md',
      sortBy: 'date',
      reverse: true
    },
    'blog_last_articles': {
      pattern: 'blog/**/*.md',
      limit: 3,
      sortBy: 'date',
      reverse: true
    },
    'blog_index': {
      pattern: 'blog.md'
    }
  }))
  .use(i18n({
    default: DEFAULT_LOCALE,
    locales: LOCALES,
    directory: './src/site/locales'
  }))
  .use(multiLanguage({
    'default': DEFAULT_LOCALE,
    'locales': LOCALES
  }))
  .use(define({
    'static_uri': static_uri,
    'app_uri': app_uri,
    'default_locale': DEFAULT_LOCALE,
    'version': 1004
  }))
  .use(markdown())
  .use(excerpts({
    pruneLength: 480,
    stripTags: false
  }))
  .use(domTransform({
    transforms: [
      codeHighlight()
    ]
  }))
  .use(permalinks({
    relative: false,
    pattern: ':locale/:title/',
    date: 'YYYY-MM',
    linksets: [
      {
        match: { collection: 'blog' },
        pattern: 'blog/:date/:title/',
      },
      {
        match: { collection: 'blog_index' },
        pattern: ':title/'
      }
    ]
  }))
  .use(moment(['published', 'date']))
  .use(feed({
    'collection': 'blog',
    'destination': 'rss_blog.xml'
  }))
  .use(extlinks({
    'domain': 'sealas.at',
    'rel': 'external',
    'target': '_blank'
  }))
  .use(sitemap({
    'hostname': site_uri,
    'omitIndex': true
  }))
  .use(layouts({
    'engine': 'swig',
    'default': 'blog-entry.tpl',
    'pattern': '**/*.html',
    'directory': './src/site'
  }))
  .build(function (err) {
      if (err) { console.error(err); }
  });
