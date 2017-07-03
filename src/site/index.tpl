{% extends 'layout.tpl' %}

{% block content %}
<section id="section-home">
	<div class="hero-header" style="padding-bottom: 0; background: url('{{ static_uri }}/lock.jpg') 50% 75%; background-repeat: no-repeat; overflow: visible; background-size: cover;">
		<div class="container container-sm clearfix">
			<div class="col-md-12 container-sm heading-block nobottomborder page-section" style="float: left; margin-top: 150px;">
				<div class="col-md-8 col-md-offset-2" style="padding: 30px; background: url('{{ static_uri }}/images/loginstripes.png') rgba(0,0,0,0.2);">
					<h1 style="font-size: 42px; margin-bottom: 1em">{{ __('header-main-title') }}</h1>

					<div class="content">
						{#}<form class="login-form">

							<div class="form-actions">
								<button type="submit" name="register" class="button button-3d button-desc button-dirty-green center col-md-12" data-bind="disable: submitted" style="margin-bottom: 50px">{{ __('cta-button') }}<span>{{ __('cta-button-subtitle') }}</span></button>
							</div>
						</form>#}
						{% include 'cta_blog.tpl' with { 'font': 'white' } %}

						<div data-bind="visible: register_done" style="display: none">
							<i class="i-bordered i-circled icon-thumbs-up" style="background-color: #1ABC9C !important;text-shadow: 1px 1px 1px rgba(0,0,0,0.2);border-color: #1ABC9C !important;"></i>
							<h1>{{ __('registration_done_header') }}</h1>
							<p>{{ __('registration_done_message') }}</p>
						</div>

						{#% if locale == 'de' %}
						<iframe height="230" src="https://www.youtube.com/embed/C2wRVFfBmTU" frameborder="0" allowfullscreen="" style="width: 100%"></iframe>
						{% else %}
						<iframe height="230" src="https://www.youtube.com/embed/3KDm09rWST4" frameborder="0" allowfullscreen="" style="width: 100%"></iframe>
						{% endif %#}
					</div>
				</div>
			</div>
		</div>
	</div>
</section>

<div class="content-wrap" id="features" style="padding-top: 0">
	{#% include 'features_content.tpl' %#}
	<div class="row section dark">
		<div class="container clearfix">
			<div class="heading-block center">
				<h2>{{ __('index_feat_block_title') }}</h2>
			</div>

			<div class="col-md-4">
				<div class="feature-box fbox-center fbox-outline fbox-effect">
					<div class="fbox-icon">
						<i class="icon-lock i-alt"></i>
					</div>
					<h2>{{ __('index_feat_zk_title') }}</h2>
					<p class="text-left">{{ __('index_feat_zk_body') | raw }}</p>

					<p>
						{% if locale == 'de' %}
						<a href="/blog/2017/warum-wir-zero-knowledge-software-entwickeln/" style="font-size: 20px">Warum Zero-Knowledge?</a>
						{% else %}
						<a href="/blog/2017/why-we-develop-zero-knowledge-software/" style="font-size: 20px">Why Zero Knowledge?</a>
						{% endif %}
					</p>
				</div>
			</div>

			<div class="col-md-4">
				<div class="feature-box fbox-center fbox-outline fbox-effect">
					<div class="fbox-icon">
						<i class="icon-heart i-alt"></i>
					</div>
					<h2>{{ __('index_feat_os_title') }}</h2>
					<p class="text-left">{{ __('index_feat_os_body') }}</p>
				</div>
			</div>

			<div class="col-md-4">
				<div class="feature-box fbox-center fbox-outline fbox-effect">
					<div class="fbox-icon">
						<i class="icon-comments i-alt"></i>
					</div>
					<h2>{{ __('index_feat_blog_title') }}</h2>
					<p class="text-left">{{ __('index_feat_blog_body') }}</p>
				</div>
			</div>

		</div>
	</div>

	<div id="section-contact" class="heading-block title-center page-section">
		<h1>{{ __('index_blog_title') }}</h1>
		<span>{{ __('index_blog_subtitle') }}</span>
	</div>

	<div class="container clearfix">
		{% for entry in collections['blog_last_articles'] %}
		<div class="entry clearfix">
			<div class="entry-title">
				<h2><a href="/{{ entry.path }}">{{ entry.title }}</a></h2>
			</div>
			<div class="entry-content">
				<p>{{ entry.excerpt | safe }}</p>
				<a href="/{{ entry.path }}" class="more-link">{{ __('blog_read_more') }}</a>
			</div>
		</div>
		{% endfor %}

		<div class="fancy-title title-border title-center">
			<h3><a href="/blog">{{ __('index_blog_more') }}</a></h3>
		</div>

		{% include 'cta_blog.tpl' %}
	</div>
</div>

{#}<div class="content-wrap" style="padding-top: 0">

	{% include 'cta.tpl' %}
</div>#}
{% endblock %}
