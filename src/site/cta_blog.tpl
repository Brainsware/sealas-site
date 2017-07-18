<div id="section-buy" class="promo promo-border">

	<div class="{% if header %}container {% endif %}clearfix">

		<div id="mc_embed_signup" class="widget subscribe-widget clearfix col-md-10 col-md-offset-1">
			<form action="//sealas.us13.list-manage.com/subscribe/post?u=26cea96bbfb24fbc5f58e314f&amp;id=a92e310c11" method="post" id="mc-embedded-subscribe-form" name="mc-embedded-subscribe-form" class="validate" target="_blank" novalidate>
				<div id="mc_embed_signup_scroll">
				<h3 style="margin-bottom: 1em;{% if font == 'white' %}color: white{% endif %}">{{ __('blog_newsletter_intro') }}</h3>

				<div class="input-group input-group-lg divcenter">
					<span class="input-group-addon"><i class="icon-email2"></i></span>
					<input type="email" value="" required="required" name="EMAIL" class="form-control required email" id="mce-EMAIL" placeholder="{{ __('blog_newsletter_placeholder') }}">

					<span class="input-group-btn">
						<button class="btn btn-success" type="submit">{{ __('blog_newsletter_subscribe') }}</button>
					</span>
				</div>
				<div id="mce-responses" class="clear">
					<div class="response" id="mce-error-response" style="display:none"></div>
					<div class="response" id="mce-success-response" style="display:none"></div>
				</div>    <!-- real people should not fill this in and expect good things - do not remove this or risk form bot signups-->
					<div style="position: absolute; left: -5000px;" aria-hidden="true"><input type="text" name="b_26cea96bbfb24fbc5f58e314f_a92e310c11" tabindex="-1" value=""></div>
					<div class="clear"><input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" class="button"></div>
					</div>
			</form>

			{% if rss %}
			<div class="blog-rss">
				<a href="{{ site.url }}/rss_blog.xml" class="social-icon si-dark si-colored si-rss nobottommargin" style="margin-right: 10px;">
					<i class="icon-rss"></i>
					<i class="icon-rss"></i>
				</a>
				<a href="{{ site.url }}/rss_blog.xml"><small style="display: inline-block; margin-top: 3px;">Get our<br><strong>RSS feed!</strong></small></a>
			</div>
			{% endif %}
		</div>
	</div>

</div>
