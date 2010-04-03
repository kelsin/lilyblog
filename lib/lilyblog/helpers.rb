module LilyBlog

  # This module contains custom helpers for use in LilyBlog views.
  #
  # Author:: Christopher Giroir (kelsin@valefor.com)
  module Helpers
    # Returns the title that should be on this page
    def title
      if @post
        @post.title
      elsif @tag
        settings.tag_title(@tag)
      elsif @search
        settings.search_title(@search)
      else
        settings.posts_title
      end
    end

    # Very simple partial function
    #
    # Takes a template name and an object to load as the main object (named the
    # same as the template name). Then takes a hash of other local variables.
    #
    # Example: partial :post, @post, :comments => true
    def partial(name, obj, locals = {})
      Array(obj).map do |item|
        haml "_#{name}".to_sym, :locals => { name.to_sym => item }.merge(locals), :layout => false
      end.join("\n")
    end

    # Like the sinatra helper for html_attrs, this returns the css tag attributes
    # for a given style sheet.
    #
    # For example, to load the /css/layout.css file use:
    # %link{ css_attrs(:layout) }
    def css_attrs(sheet, media = 'all')
      { :rel => 'stylesheet',
        :type => 'text/css',
        :href => "/css/#{sheet}.css",
        :media => media }
    end

    # Given a post model, this returns the url of the post (for linking)
    def post_url(post)
      "/#{'%02d' % post.filedate.year}/#{'%02d' % post.filedate.month}/#{'%02d' % post.filedate.day}/#{post.slug}/"
    end

    # This returns an array of [feed_name, feed_url] for any feeds applicable to
    # the current page.
    def feed_urls
      urls = [[settings.posts_title, '/feed/']]

      if word = @tag || @search
        urls.push [settings.tag_title(word), "#{tag_url(word)}feed/"]
        urls.push [settings.search_title(word), "#{search_url(word)}feed/"]
      end

      return urls
    end

    # This returns the feed url for the current page
    def feed_url
      if @tag
        "#{tag_url(@tag)}feed/"
      elsif @search
        "#{search_url(@search)}feed/"
      else
        '/feed/'
      end
    end

    # Returns the search url for a given term.
    def search_url(search)
      "/search/#{search}/"
    end

    # Returns the tag url for a given tag
    def tag_url(tag)
      "/tags/#{tag}/"
    end

    # The maximum page needed to show all posts
    #
    # I would like to put this in the model, but it needs to know if we're on a
    # tag page or not
    def max_page
      (Post.count(@tag).to_f / Post.page_size.to_f).ceil
    end

    # Adds the page parameter onto the current url for a given page
    def page_url(page)
      "#{request.path}?page=#{page}"
    end

    # Adds the page parameter onto the current url for the next page
    def next_page_url
      "#{request.path}?page=#{@page + 1}"
    end

    # Adds the page parameter onto the current url for the previous page
    def prev_page_url
      if @page <= 2
        request.path
      else
        "#{request.path}?page=#{@page - 1}"
      end
    end

    # Returns the class name to use on a tag link
    def class_for_tag(tag)
      case Post.tag(tag)
      when 0.0...0.02
        'tiny'
      when 0.02...0.04
        'small'
      when 0.04...0.06
        'medium'
      when 0.06...0.08
        'large'
      when 0.08..1.0
        'enormous'
      end
    end
  end
end
