(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var u;

window.onscroll = function(e) {
  if (document.body.scrollTop > 1) {
    return document.getElementById('header').classList.add('sticky-header');
  } else if (document.body.scrollTop === 0) {
    return document.getElementById('header').classList.remove('sticky-header');
  }
};

document.querySelectorAll('#primary-menu-trigger,#overlay-menu-close').forEach(function(e) {
  return e.onclick = function() {
    if (document.getElementById('primary-menu').getElementsByClassName('mobile-primary-menu') > 0) {
      document.querySelectorAll('#primary-menu > ul.mobile-primary-menu, #primary-menu > div > ul.mobile-primary-menu').forEach(function(e) {
        return e.classList.toggle("show");
      });
    } else {
      document.querySelectorAll('#primary-menu > ul, #primary-menu > div > ul').forEach(function(e) {
        return e.classList.toggle("show");
      });
    }
    return false;
  };
});

window._paq = window._paq || [];

u = 'https://stats.esotericsystems.at/';

window._paq.push(['setTrackerUrl', u + 'piwik.php']);

window._paq.push(['setSiteId', 13]);

window._paq.push(['trackPageView']);

window._paq.push(['enableLinkTracking']);

(function() {
  var d, g, s;
  d = document;
  g = d.createElement('script');
  s = d.getElementsByTagName('script')[0];
  g.type = 'text/javascript';
  g.async = true;
  g.defer = true;
  g.src = u + 'piwik.js';
  return s.parentNode.insertBefore(g, s);
})();


},{}]},{},[1]);
