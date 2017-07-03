
	<div class="row section dark">
		<div class="container clearfix">
		<div class="heading-block center">
			<h2>{{ __('feat_encryption-title') }}</h2>
			<span>{{ __('feat_encryption-body') | raw }}</span>
		</div>
		<div class="center">
			{% if locale == 'de' %}
			<a href="/de/blog/2017/warum-wir-zero-knowledge-software-entwickeln/" style="font-size: 20px">Warum Zero-Knowledge?</a>
			{% else %}
			<a href="/en/blog/2017/why-we-develop-zero-knowledge-software/" style="font-size: 20px">Why Zero Knowledge?</a>
			{% endif %}
		</div>
		</div>
	</div>

	<div class="container clearfix">

		<div class="row topmargin-lg">
			<div class="col-md-5">
				<div class="heading-block">
					<h3>{{ __('feat_invoicing-title') }}</h3>
					<span>{{ __('feat_invoicing-subtitle') }}</span>
				</div>
				<p>
					{{ __('feat_invoicing-body') }}
				</p>
			</div>
			<div class="col-md-7">
				<a href="{{ static_uri }}/images/site/invoices1.png" class="popup-img"><img src="{{ static_uri }}/images/site/invoices1.png" alt="" /></a>
			</div>
		</div>

	</div>
	<div class="section">
		<div class="container clearfix">
			<div class="row">
				<div class="col-md-7">
					<a href="{{ static_uri }}/images/site/stats.png" class="popup-img"><img src="{{ static_uri }}/images/site/stats.png" alt="" /></a>
				</div>
				<div class="col-md-5">
					<div class="heading-block">
						<h3>{{ __('feat_stats-title') }}</h3>
						<span>{{ __('feat_stats-subtitle') }}</span>
					</div>
					<p>
						{{ __('feat_stats-body') }}
					</p>
				</div>
			</div>
			</div>
	</div>
	<div class="container clearfix">

		<div class="row">
			<div class="col-md-5">
				<div class="heading-block">
					<h3>{{ __('feat_expenses-title') }}</h3>
					<span>{{ __('feat_expenses-subtitle') }}</span>
				</div>
				<p>{{ __('feat_expenses-body') }}</p>
			</div>
			<div class="col-md-7">
				<a href="{{ static_uri }}/images/site/expense.jpg" class="popup-img"><img src="{{ static_uri }}/images/site/expense.jpg" alt="" /></a>
			</div>
		</div>

	</div>
	<div class="section">
		<div class="container clearfix">
			<div class="row">
				<div class="col-md-7">
					<a href="{{ static_uri }}/images/site/contacts.jpg" class="popup-img"><img src="{{ static_uri }}/images/site/contacts.jpg" alt="" /></a>
				</div>
				<div class="col-md-5">
					<div class="heading-block">
						<h3>{{ __('feat_contacts-title') }}</h3>
						<span>{{ __('feat_contacts-subtitle') }}</span>
					</div>
					<p>{{ __('feat_contacts-body') }}</p>
				</div>
			</div>
		</div>
	</div>
