{% extends 'layout.tpl' %}

{% block content %}
	<div class="clearfix" style="padding: 0;margin-bottom: 0;border:0">
		{% include 'cta_blog.tpl' with { 'rss': true, 'header': true } %}
	</div>

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
