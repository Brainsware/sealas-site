(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var _paq;

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
      return document.querySelectorAll('#primary-menu > ul.mobile-primary-menu, #primary-menu > div > ul.mobile-primary-menu').forEach(function(e) {
        return e.classList.toggle("show");
      });
    } else {
      return document.querySelectorAll('#primary-menu > ul, #primary-menu > div > ul').forEach(function(e) {
        return e.classList.toggle("show");
      });
    }
  };
});

false;

_paq = _paq || [];

_paq.push(['trackPageView']);

_paq.push(['enableLinkTracking']);

(function() {
  var d, g, s, u;
  u = '//stats.esotericsystems.at/';
  _paq.push(['setTrackerUrl', u + 'piwik.php']);
  _paq.push(['setSiteId', 13]);
  d = document;
  g = d.createElement('script');
  s = d.getElementsByTagName('script')[0];
  g.type = 'text/javascript';
  g.async = true;
  g.defer = true;
  g.src = u + 'st.js';
  s.parentNode.insertBefore(g, s);
})();


},{}]},{},[1]);
