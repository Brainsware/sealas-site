{% extends 'layout.tpl' %}

{% block content %}
<div class="content-wrap" style="padding-top: 0">
	<div class="container clearfix">

		<div id="section-faqs" class="heading-block title-center page-section topmargin">
			{#}<h2>{{ __('about') }}</h2>#}
			<h2>{{ __('about_values') }}</h2>
		</div>

		<div class="entry nobottommargin">
			{{ contents | safe }}
		</div>

		<div id="section-faqs" class="heading-block title-center page-section topmargin">
			{#}<h2>{{ __('about') }}</h2>#}
			<h2>{{ __('about_team') }}</h2>
		</div>

		<div class="row">
			<div class="col-md-6 col-sm-12 bottommargin">
				<div class="team team-list clearfix">
					<div class="team-image">
						<img src="{{ static_uri }}/images/site/team/dk2.jpg" alt="Daniel Khalil" style="max-width: 256px">
					</div>
					<div class="team-desc">
						<div class="team-title"><h4>Daniel Khalil</h4><span>{{ __('team_dk_title') }}</span></div>
						<div class="team-content">
							<p>{{ __('team_dk_text') }}</p>
						</div>
					</div>
				</div>
			</div>

			<div class="col-md-6 col-sm-12 bottommargin">
				<div class="team team-list clearfix">
					<div class="team-image">
						<img src="{{ static_uri }}/images/site/team/ig2.jpg" alt="Igor Galic">
					</div>
					<div class="team-desc">
						<div class="team-title"><h4>Igor Galić</h4><span>{{ __('team_ig_title') }}</span></div>
						<div class="team-content">
							<p>{{ __('team_ig_text') }}</p>
						</div>
					</div>
				</div>
			</div>
		</div>

		{# FAQ #}
		<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
		<div id="section-faqs" class="heading-block title-center page-section">
			{#}<h2>{{ __('about') }}</h2>#}
			<h2>{{ __('faq_whysealas_title') }}</h2>
		</div>

		<div class="entry nobottommargin">
			{{ __('faq_whysealas') }}
		</div>
	</div>

	{% include 'cta.tpl' %}
</div>
{% endblock %}
