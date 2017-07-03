{% extends 'layout.tpl' %}

{% block content %}
<section id="page-title" class="page-title-nobg">
	<div class="container entry clearfix" style="padding: 0;margin-bottom: 0;border:0">
		<h1 style="padding-top: 10px">{{ __('blog_title') }}</h1>
		<span>{{ __('blog_subtitle') }}</span>

		<div class="blog-rss">
			<a href="{{ site.url }}/rss_{{ locale }}.xml" class="social-icon si-dark si-colored si-rss nobottommargin" style="margin-right: 10px;">
				<i class="icon-rss"></i>
				<i class="icon-rss"></i>
			</a>
			<a href="{{ site.url }}/rss_{{ locale }}.xml"><small style="display: inline-block; margin-top: 3px;">Get our<br><strong>RSS feed!</strong></small></a>
		</div>
	</div>
</section>
<section id="content">
<div class="content-wrap">
	<div class="container clearfix">
		{% for entry in collections['blog'] %}
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

		{% include 'cta_blog.tpl' %}
	</div>
</div>
</section>
{% endblock %}
