{% extends 'layout.tpl' %}

{% block title %}{{ title }} - {% endblock %}

{% block head_meta %}
<meta name="twitter:card"       content="summary">
<meta name="twitter:site"       content="@sealasapp">
<meta property="og:url"         content="{{ site_uri }}/{{ path }}">
<meta property="og:title"       content="{{ title }}">
<meta property="og:type"        content="article">
<meta property="og:description" content="{{ excerpt }}">
<meta property="og:image"       content="{{ site_uri }}/images/sealas-logo-white-yellow.png">
{% endblock %}

{% block content %}
<section id="content">
<div class="content-wrap">
	<div class="container clearfix">
		<div class="entry clearfix">
			<div class="entry-title">
				<h1>{{ title }}</h1>
			</div>

			<ul class="entry-meta clearfix">
				<li><i class="icon-calendar3"></i> {{ date.format('DD.MM.YYYY') }}</li>
			</ul>

			<div class="entry-content">
				{{ contents | safe }}
			</div>

			<div class="si-share noborder clearfix">
					<span>Share this Post:</span>
					<div>
						<div id="fb-root"></div>
						<script>(function(d, s, id) {
						  var js, fjs = d.getElementsByTagName(s)[0];
						  if (d.getElementById(id)) return;
						  js = d.createElement(s); js.id = id;
						  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
						  fjs.parentNode.insertBefore(js, fjs);
						}(document, 'script', 'facebook-jssdk'));</script>

							<fb:like href='{{ site_uri }}/{{ path }}'
	         send='false'
	         layout='button'
	         show_faces=''
	         width='80'
	         action=''
	         font=''
	         colorscheme=''
	         ref='' ></fb:like>

					 <a href="https://twitter.com/share" class="twitter-share-button" data-text="{{ title }}" data-url="{{ site_uri }}/{{ path }}" data-via="SealasApp" data-dnt="true" data-show-count="false">Tweet</a><script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

					 <!-- Place this tag where you want the +1 button to render. -->
					<div class="g-plusone" data-size="medium" data-annotation="none" data-callback="{{ site_uri }}/{{ path }}"></div>

					<!-- Place this tag after the last +1 button tag. -->
					<script type="text/javascript">
					  (function() {
					    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
					    po.src = 'https://apis.google.com/js/platform.js';
					    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
					  })();
					</script>

					<script src="//platform.linkedin.com/in.js" type="text/javascript"> lang: en_US</script>
<script type="IN/Share" data-url="{{ site_uri }}/{{ path }}"></script>
					</div>
				</div>

		</div>
		{% include 'cta_blog.tpl' %}
	</div>

</div>
</section>
{% endblock %}
