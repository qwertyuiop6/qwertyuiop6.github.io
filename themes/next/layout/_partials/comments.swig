{% if page.comments %}

  {% if (theme.duoshuo and theme.duoshuo.shortname) or theme.duoshuo_shortname %}
    <div class="comments" id="comments">
      <div class="ds-thread" data-thread-key="{{ page.path }}"
           data-title="{{ page.title }}" data-url="{{ page.permalink }}">
      </div>
    </div>

  {% elseif theme.facebook_sdk.enable and theme.facebook_comments_plugin.enable %}
    <div class="comments" id="comments">
      <div class="fb-comments"
           data-href="{{ page.permalink }}"
           data-numposts="{{ theme.facebook_comments_plugin.num_of_posts }}"
           data-width="{{ theme.facebook_comments_plugin.width }}"
           data-colorscheme="{{ theme.facebook_comments_plugin.scheme }}">
      </div>
    </div>

  {% elseif theme.vkontakte_api.enable and theme.vkontakte_api.comments %}
    <div class="comments" id="comments">
      <div id="vk_comments"></div>
    </div>

  {% elseif theme.disqus.enable %}
    <div class="comments" id="comments">
      <div id="disqus_thread"></div>
<script>

/**
*  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
*  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/
/*
var disqus_config = function () {
this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
};
*/
(function() { // DON'T EDIT BELOW THIS LINE
var d = document, s = d.createElement('script');
s.src = 'https://shadow771.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
                            
    </div>

  {% elseif theme.hypercomments_id %}
    <div class="comments" id="comments">
      <div id="hypercomments_widget"></div>
    </div>

  {% elseif theme.youyan_uid %}
    <div class="comments" id="comments">
      <div id="uyan_frame"></div>
    </div>

  {% elseif theme.livere_uid %}
    <div class="comments" id="comments">
      <div id="lv-container" data-id="city" data-uid="{{ theme.livere_uid }}"></div>
    </div>

  {% elseif theme.changyan.appid and theme.changyan.appkey %}
    <div class="comments" id="comments">
      <div id="SOHUCS"></div>
    </div>

  {% elseif theme.gitment.enable %}
    <div class="comments" id="comments">
      {% if theme.gitment.lazy %}
        <div onclick="showGitment()" id="gitment-display-button">{{ __('gitmentbutton') }}</div>
        <div id="gitment-container" style="display:none"></div>
      {% else %}
        <div id="gitment-container"></div>
      {% endif %}
    </div>

  {% elseif theme.valine.appid and theme.valine.appkey %}
    <div class="comments" id="comments">
      <div id="vcomments"></div>
    </div>
  {% endif %}

{% endif %}
