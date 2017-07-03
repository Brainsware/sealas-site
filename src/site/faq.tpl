{% extends 'layout.tpl' %}

{% block content %}
<div class="content-wrap" style="padding-top: 0">
	<div class="container clearfix">
		{# FAQ #}

		<div class="clear"></div>
		<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
		<div id="section-faqs" class="heading-block title-center page-section">
			<h2>{{ __('faq_heading') }}</h2>
		</div>

		<div class="col-md-6 nobottommargin">
			<h4>{{ __('faq_encryption_title') }}</h4>
			{{ __('faq_encryption') }}
		</div>

		<div class="col-md-6 nobottommargin">
			<h4>{{ __('faq_lostpassword_title') }}</h4>
			{{ __('faq_lostpassword') }}
		</div>

	</div>

	{% include 'cta.tpl' %}
</div>
{% endblock %}
