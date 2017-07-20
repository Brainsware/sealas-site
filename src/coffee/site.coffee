window.onscroll = (e) ->
  if document.body.scrollTop > 1
    document.getElementById('header').classList.add 'sticky-header'
  else if document.body.scrollTop == 0
    document.getElementById('header').classList.remove 'sticky-header'

document.querySelectorAll('#primary-menu-trigger,#overlay-menu-close').forEach (e) -> e.onclick = ->
  if document.getElementById('primary-menu').getElementsByClassName('mobile-primary-menu') > 0
	  document.querySelectorAll( '#primary-menu > ul.mobile-primary-menu, #primary-menu > div > ul.mobile-primary-menu' ).forEach (e) -> e.classList.toggle("show")
  else
    document.querySelectorAll( '#primary-menu > ul, #primary-menu > div > ul' ).forEach (e) -> e.classList.toggle("show")

	false

_paq = _paq or []
_paq.push [ 'trackPageView' ]
_paq.push [ 'enableLinkTracking' ]
do ->
  u = '//stats.esotericsystems.at/'
  _paq.push [
    'setTrackerUrl'
    u + 'piwik.php'
  ]
  _paq.push [
    'setSiteId'
    13
  ]
  d = document
  g = d.createElement('script')
  s = d.getElementsByTagName('script')[0]
  g.type = 'text/javascript'
  g.async = true
  g.defer = true
  g.src = u + 'st.js'
  s.parentNode.insertBefore g, s
  return
