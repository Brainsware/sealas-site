<!DOCTYPE html>
<html lang="{{ locale }}">
<head>
	<title>{{ __('site_title') }}</title>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta content="width=device-width, initial-scale=1" name="viewport"/>

  <meta name="robots" content="index,follow">
	<meta name="description" content="{{ __('meta_description') }}">

	<link rel="alternate" hreflang="de" href="https://sealas.at/" />
	<link rel="alternate" hreflang="en" href="https://sealas.at/en" />

  <link href="{{ static_uri }}/vendor/open-sans-fontface/open-sans.css" rel="stylesheet" type="text/css"/>
	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/vendor/lato/css/lato.min.css">
	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/vendor/fonts-raleway/css/raleway.min.css">
	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/styles/site/font-icons.css?v={{ version }}">
	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/styles/font/crete/stylesheet.css?v={{ version }}">

	<link rel="icon" href="{{ static_uri }}/images/sealas-logo-yellow.png" />
	<link rel="shortcut icon" href="{{ static_uri }}/images/favicon.ico" />

	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/styles/front.css?v={{ version }}">
	<link rel="stylesheet" type="text/css" href="{{ static_uri }}/styles/site.css?v={{ version }}">

	{% block head_meta %}
	<meta property="og:image" content="{{ static_uri }}/images/sealas-logo-white-yellow.png">
	{% endblock %}

	</head>
	{% set locale_link = '' %}
	{% if locale != default_locale %}{% set locale_link = locale + '/' %}{% endif %}
	{% set locale_flag = 'at' %}
	{% if locale != 'de' %}{% set locale_flag = 'gb' %}{% endif %}
<body>
	<header id="header">

			<div id="header-wrap">

				<div class="container clearfix">

					<div id="primary-menu-trigger"><i class="icon-reorder"></i></div>
					<div id="logo">
						<a href="/{{ locale_link }}" class="standard-logo" data-dark-logo="images/logo-dark.png"><img src="{{ static_uri }}/images/sealas-logo-white-yellow.png" alt="{{ __('site_title') }}"></a>
						<a href="/{{ locale_link }}" class="retina-logo" data-dark-logo="images/logo-dark@2x.png"><img src="{{ static_uri }}/images/sealas-logo-white-yellow.png" alt="{{ __('site_title') }}"></a>
					</div><!-- #logo end -->

					<nav id="primary-menu">
						<ul class="one-page-menu sf-js-enabled" style="touch-action: pan-y;">
							{#}<li><a href="/{{ locale }}/features"><div>{{ __('features') }}</div></a></li>#}
							<li><a href="/{{ locale }}/about"><div>{{ __('about') }}</div></a></li>
							<li><a href="/{{ locale }}/pricing"><div>{{ __('pricing') }}</div></a></li>
							{#}<li><a href="/{{ locale }}/faq"><div>{{ __('faq') }}</div></a></li>#}
							<li><a href="https://github.com/brainsware/sealas" target="_blank"><div>{{ __('github') }}</div></a></li>
							<li><a href="/blog/"><div>{{ __('blog') }}</div></a></li>
						</ul>

						{#}<ul class="one-page-menu sf-js-enabled login-menu" style="touch-action: pan-y;">
							<li>
								<a href="{{ app_uri }}/#login" class="btn yellow-sealas">{{ __('to-login') }}</a>
							</li>
						</ul>#}

						<ul class="one-page-menu sf-js-enabled lang-menu">
							<li><a><img src="{{ static_uri }}/images/flags/{{ locale_flag }}.png" alt="" /> {{ locale }}</a>
								<ul>
									<li><a href="/de"><img src="{{ static_uri }}/images/flags/at.png" alt="" /> de</a></li>
									<li><a href="/en"><img src="{{ static_uri }}/images/flags/gb.png" alt="" /> en</a></li>
								</ul>
							</li>
						</ul>

					</nav>

				</div>

			</div>

		</header>

		<div class="clear"></div>

{% block content %}404{% endblock %}

	<footer id="footer" class="dark" style="background: url('{{ static_uri }}/styles/site/images/footer-bg.jpg') repeat fixed; background-size: 100% 100%;">

		<div class="container">

			{# Footer Widge #}
			<div class="footer-widgets-wrap clearfix">

				<div class="col_three_fifth">

					<div class="widget clearfix">

						<img src="{{ static_uri }}/images/sealas-logo-yellow-side.png" alt="{{ __('site_title') }}" class="alignleft" id="footer-logo">

						<h3>{{ __('footer_description') }}</h3>

						<div class="line" style="margin: 30px 0;"></div>
						<div class="clearfix" style="padding: 10px 0;">
							<div class="col_half">
								<address class="nobottommargin">
									<abbr title="Headquarters" style="display: inline-block;margin-bottom: 7px;"><strong>{{ __('footer_imprint') }}:</strong></abbr><br>
									{{ __('footer_serviceby') }}<br>
									<a href="https://brainsware.at" target="_blank">Brainsware OG</a><br>
									Liechtensteinstraße 119/21<br>
									A-1090 Wien
								</address>
							</div>
							<div class="col_half col_last">
								<br>ATU68014409<br />
								HG Wien, FN 330963k<br />
								<abbr title="Email Address"><strong>{{ __('contact_email') }}:</strong></abbr> <a href="mailto:contact@sealas.at">contact@sealas.at</a><br>
								<abbr title="Web"><strong>{{ __('contact_web') }}:</strong></abbr> <a href="https://brainsware.at">https://brainsware.at</a><br>
							</div>
						</div>
					</div>

				</div>

				<div class="col_one_fifth">
					<div class="bottommargin-sm widget_links">
						<ul>
							<li><a href="/{{ locale_link }}">{{ __('home') }}</a></li>
							<li><a href="/{{ locale }}/about">{{ __('about') }}</a></li>
							<li><a href="/{{ locale_link }}#features">{{ __('features') }}</a></li>
							{#<li><a href="/{{ locale }}/features">{{ __('features') }}</a></li>#}
							<li><a href="/{{ locale }}/pricing">{{ __('pricing') }}</a></li>
							{#}<li><a href="/{{ locale }}/faq">{{ __('faq') }}</a></li>#}
							<li><a href="https://github.com/brainsware/sealas-site">{{ __('github-site') }}</a></li>
							<li><a href="https://github.com/brainsware/sealas">{{ __('github-app') }}</a></li>
						</ul>
					</div>
				</div>
				<div class="col_one_fifth col_last">
					<div class="bottommargin-sm widget_links">
						<ul>
							<li><a href="/{{ locale }}/blog/"><div>{{ __('blog') }}</div></a></li>
							<li><a href="/{{ locale }}/contact">{{ __('contact') }}</a></li>
							<li><a href="/{{ locale }}/agb">{{ __('tos') }}</a></li>
							<li><a href="/{{ locale }}/privacy">{{ __('privacypolicy') }}</a></li>
						</ul>
					</div>
				</div>

			</div>

		</div>

		{# Copyright #}
		<div id="copyrights">

			<div class="container clearfix">

				<div class="col_half">
					&copy; Brainsware OG
				</div>

				<div class="col_half col_last tright">
					<div class="fright clearfix">
						<a href="https://facebook.com/sealasapp" target="_blank" class="social-icon si-small si-borderless nobottommargin si-facebook">
							<i class="icon-facebook"></i>
							<i class="icon-facebook"></i>
						</a>

						<a href="https://twitter.com/sealasapp" target="_blank" class="social-icon si-small si-borderless nobottommargin si-twitter">
							<i class="icon-twitter"></i>
							<i class="icon-twitter"></i>
						</a>

						{#}<a href="https://vimeo.com/sealas" target="_blank" class="social-icon si-small si-borderless nobottommargin si-vimeo">
							<i class="icon-vimeo"></i>
							<i class="icon-vimeo"></i>
						</a>#}

						<a href="https://plus.google.com/+SealasAt" target="_blank" class="social-icon si-small si-borderless nobottommargin si-gplus">
							<i class="icon-gplus"></i>
							<i class="icon-gplus"></i>
						</a>

						<a href="https://www.linkedin.com/company/sealas" target="_blank" class="social-icon si-small si-borderless nobottommargin si-linkedin">
							<i class="icon-linkedin"></i>
							<i class="icon-linkedin"></i>
						</a>

						<a href="https://github.com/brainsware" target="_blank" class="social-icon si-small si-borderless nobottommargin si-github">
							<i class="icon-github"></i>
							<i class="icon-github"></i>
						</a>
					</div>
				</div>

			</div>

		</div>{# #copyrights end #}

	</footer>{# #footer end #}

	<script type="text/javascript" src="/site.js">
	</script>

	<noscript><p><img src="//stats.esotericsystems.at/piwik.php?idsite=13" style="border:0;" alt="" /></p></noscript>
</body>
</html>
