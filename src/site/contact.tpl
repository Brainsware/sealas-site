{% extends 'layout.tpl' %}

{% block content %}
<div class="content-wrap" style="padding-top: 0">
	<div class="container clearfix">
		{# Contact #}
		<div class="clear"></div>
		<div class="divider divider-short divider-center"><i class="icon-circle"></i></div>
		<div id="section-contact" class="heading-block title-center page-section">
			<h2>{{ __('contact') }}</h2>
			<span>{{ __('contact_subtitle') }}</span>

			<p>
				<a href="https://facebook.com/sealasapp" target="_blank" class="social-icon si-dark si-colored si-facebook nobottommargin" style="margin-right: 10px;">
					<i class="icon-facebook"></i>
					<i class="icon-facebook"></i>
				</a>

				<a href="https://twitter.com/sealasapp" target="_blank" class="social-icon si-dark si-colored si-twitter nobottommargin" style="margin-right: 10px;">
					<i class="icon-twitter"></i>
					<i class="icon-twitter"></i>
				</a>
			</p>
		</div>

		<div class="entry">
			<p>{{ __('contact_text') }} <a href="mailto:contact@sealas.at">contact@sealas.at</a></p>
		</div>

		{#}<form class="nobottommargin" id="contactform" name="contactform"  method="post" data-bind="submit: sendMessage, visible: !message_sent()">
			<div class="form-process"></div>

			<div class="col-md-12" style="margin-bottom: 30px">
				<label for="contactform-message">{{ __('contact_message') }} <small>*</small></label>
				<textarea class="required sm-form-control" id="contactform-message" name="contactform-message" rows="6" cols="30" required="required"></textarea>
			</div>

			<div class="clear"></div>

			<div class="col-md-6">
				<label for="contactform-email">{{ __('contact_email') }} <small>*</small></label>
				<input type="email" id="contactform-email" name="contactform-email" value="" class="required email sm-form-control" required="required">
			</div>

			<div class="col-md-6">
				<label for="contactform-name">{{ __('contact_name') }}</label>
				<input type="text" id="contactform-name" name="contactform-name" value="" class="sm-form-control required">
			</div>

			<div class="col-md-12 hidden">
				<input type="text" id="contactform-botcheck" name="contactform-botcheck" value="" class="sm-form-control">
			</div>

			<div class="col-md-12" style="margin-top: 30px">
				<button class="button button-3d nomargin" type="submit" id="contactform-submit" name="contactform-submit" value="submit">{{ __('contact_submit') }}</button>
			</div>

		</form>
		<p id="contact_sent_message" style="display: none">{{ __('contact_sent_message') }}</p>#}
		<div class="clear"></div>
	</div>

	<div class="container clearfix">
		{% include 'cta_blog.tpl' %}
	</div>
</div>
{% endblock %}
