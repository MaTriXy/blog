# Title: Simple Image tag for Jekyll
# Authors: Brandon Mathis http://brandonmathis.com
#          Felix Schäfer, Frederic Hemberger
# Description: Easily output images with optional class names, width, height, title and alt attributes
#
# Syntax {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | "title text" ["alt text"]] %}
#
# Examples:
# {% img /images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png Ninja Attack! %}
# {% img left half http://site.com/images/ninja.png 150 150 "Ninja Attack!" "Ninja in attack posture" %}
#
# Output:
# <img src="/images/ninja.png">
# <img class="left half" src="http://site.com/images/ninja.png" title="Ninja Attack!" alt="Ninja Attack!">
# <img class="left half" src="http://site.com/images/ninja.png" width="150" height="150" title="Ninja Attack!" alt="Ninja in attack posture">
#

module Jekyll

  class NoteTag < Liquid::Block

    @title = nil

    def initialize(tag_name, markup, tokens)
      @title = markup
      super
    end

    def render(context)
      output = super(context)
      title = "Note"
      if !@title.empty?
        title += ": #{@title}"
      end

      %|</section>\n<div class="note"><span class="title">#{title}</span>#{output}</div>\n<section>|
    end
  end
end

Liquid::Template.register_tag('note', Jekyll::NoteTag)
