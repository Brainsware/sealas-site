{% extends 'layout.tpl' %}

{% block content %}
<div class="content-wrap" style="padding-top: 0">
	<div class="container clearfix">
		{# FAQ #}

		<div class="clear"></div>
		<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
		<div id="section-faqs" class="heading-block title-center page-section">
			<h2>{#{ __('') }#}</h2>
		</div>

		{{ contents | raw }}

	</div>

	{% include 'cta.tpl' %}
</div>
{% endblock %}
