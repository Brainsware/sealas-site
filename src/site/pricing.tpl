{% extends 'layout.tpl' %}

{% block content %}
	{# Pricing #}
<div class="content-wrap" style="padding-top: 0">
	<div class="container clearfix">
	<div class="clear"></div>
	<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
	<div class="container clearfix">
			<h3>{{ __('pricing_beginning') }}</h3>
		{% include 'cta_blog.tpl' %}
	</div>
	<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
	<div id="section-contact" class="heading-block title-center page-section">
		<h1>{{ __('pricing_title') }}</h1>
		<span>{{ __('pricing_subtitle') }}</span>
	</div>

	<div id="section-pricing" class="pricing-box pricing-extended clearfix">

		<div class="pricing-desc" style="width: 100%">
			<div class="pricing-features">
				{{ contents | safe }}
			</div>
		</div>
	</div>
	<div class="pricing pricing-2 bottommargin clearfix">

		<div class="pricing-box pricing-minimal col-md-12 best-price">
			<div class="pricing-price">
				{{ __('pricing_starting_at') }} <span class="price-unit">€</span>0<span class="price-tenure">/ {{ __('month') }}</span>
			{#}<p style="color: #999; font-size: 16px; margin: 0">{{ __('plus_vat') }}</p>#}</div>

		</div>

		{#}<div class="pricing-action clearfix">
			<div class="form-actions">
				<a href="{{ app_uri }}/user/#register" class="button button-3d button-desc button-dirty-green center col-md-12" style="margin-bottom: 50px">{{ __('cta-button') }}<span>{{ __('cta-button-subtitle') }}</span></a>
			</div>
		</div>#}

	</div>

	<div class="clear"></div>
	<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>

	<div class="entry">
		{{ faq | safe }}
	</div>

	</div>
</div>
{% endblock %}
