# Title: Simple Adsense tag for Jekyll
# Authors: Ryan Harter http://ryanharter.com
# Description: Easily add Adsense ads to any section of your site.
#
# Syntax {% adsense [ad style] [ad type] %}
#
# Examples:
# {% adsense %}
#
# Output:
# <script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
# <!-- ryanharter.com -->
# <ins class="adsbygoogle"
#      style="display:inline-block;width:728px;height:90px"
#      data-ad-client="ca-pub-5083518921122865"
#      data-ad-slot="6075839072"></ins>
# <script>
# (adsbygoogle = window.adsbygoogle || []).push({});
# </script>
#

module Jekyll

  class AdsenseTag < Liquid::Tag

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      "<script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>
       <!-- ryanharter.com -->
       <ins class=\"adsbygoogle\"
            style=\"display:inline-block;width:728px;height:90px\"
            data-ad-client=\"ca-pub-5083518921122865\"
            data-ad-slot=\"6075839072\"></ins>
       <script>
       (adsbygoogle = window.adsbygoogle || []).push({});
       </script>"
    end
  end
end

Liquid::Template.register_tag('adsense', Jekyll::AdsenseTag)
