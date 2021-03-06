# For the other gems
require 'rubygems'

# Grepper - Grepping through files
require 'grepper'

# HtmlEntities - Decoding html entities
require 'htmlentities'

# Ultraviolet - Code highlighting
require 'uv'

# RDiscount - Markdown
require 'rdiscount'

module LilyBlog

  # Main post class for LilyBlog
  #
  # The initialize method for Post requires a filename to load.  Post files are
  # a section of yaml, followed by a blank line and then a post formatted with
  # Markdown. Please see the README file for more information about how to
  # format posts that this class uses.
  #
  # Author:: Christopher Giroir (kelsin@valefor.com)
  class Post
    # This is used to decode html entities from markdown output
    @@coder = HTMLEntities.new

    attr_reader :meta, :file

    class << self

      # Sets the theme to use with Ultraviolet
      def theme=(theme)
        @@theme = theme
      end

      # Returns the theme to use with Ultraviolet
      def theme
        @@theme || 'twilight'
      end

      # Sets the page size
      def page_size=(size)
        @@page_size = size
      end

      # Gets the page size
      def page_size
        @@page_size || 10
      end

      # Greps the post files for a pattern, returns an array of filenames that match
      def grep(pattern)
        g = Grepper.new
        g.pattern = pattern
        g.files = files
        g.run

        matches = []

        g.results.each do |file, hits|
          matches << file if hits.size > 0
        end

        matches
      end

      # Returns an array of all post filenames
      def files(tag = nil)
        if tag
          grep(/^tags:.*#{tag}/)
        else
          Dir.glob(File.join(LILYBLOG_ROOT, 'posts','*.post')).sort.reverse
        end
      end

      # Given a page it returns a range to use on an array of files to get that
      # page number
      def limit(page)
        offset = (page - 1) * @@page_size
        offset..(offset + (@@page_size - 1))
      end

      # Returns all of the posts
      def all
        files.map { |p| Post.new(p) }
      end

      # Returns a page of posts
      def get(page = 1)
        paged = files[limit(page)]

        paged ? paged.map { |p| Post.new(p) } : []
      end

      # Total number of posts
      def count(tag = nil)
        files(tag).size
      end

      # Returns all of the posts with a certain tag
      def find_by_tag(tag, page = 1)
        paged = files(tag)[limit(page)]

        paged ? paged.map { |p| Post.new(p) } : []
      end

      # Returns all of the posts containing a string
      def search(pattern)
        grep(/#{pattern}/i).map { |p| Post.new(p) }
      end

      # Find a post by name
      def find(name, allow_draft = false)
        post = File.join(LILYBLOG_ROOT, 'posts', "#{name}.post")
        draft = File.join(LILYBLOG_ROOT, 'posts', "#{name}.draft")

        if File.exists? post
          Post.new(post)
        elsif allow_draft and File.exists? draft
          Post.new(draft)
        end
      end

      # Returns the percent use of a tag
      def tag(tag)
        tags[tag].to_f / number_of_tags
      end

      # Returns all of the tags
      def tags
        counts = {}

        files.map do |file|
          Post.new(file).tags.each do |tag|
            counts[tag] ||= 0
            counts[tag] += 1
          end
        end

        return counts
      end

      # Returns the total number of tags (used to find tag percent use)
      def number_of_tags
        total = 0

        self.tags.each do |tag, amount|
          total += amount
        end

        return total.to_f
      end

      # Strips, removes bad characters and downcases a tag
      def clean_tag(tag)
        tag.strip.gsub(/[^0-9a-zA-Z_-]+/, '_').downcase
      end
    end

    # Loads a post from a file
    def initialize(file)
      @file = file

      File.open(file, 'r') do |file|
        data,@body = file.read.split(/\n\n/, 2)

        @meta = {}
        YAML::load(data).each do |key, val|
          @meta[key.to_sym] = val
        end
      end
    end

    # Runs the body of the post through RDiscount and Ultaraviolet
    #
    # If you pass in :raw as the only argument you get the body strait from the file
    def body(format = nil)
      return @body if format == :raw

      highlight
    end

    # The title of the post
    def to_s
      @meta[:title]
    end

    # Turns the tags into symbols and returns an array of them
    def tags
      @meta[:tags].split(',').map do |tag|
        Post.clean_tag(tag)
      end
    end

    # Allows you to grab meta elements using normal methods
    def method_missing(id, *args)
      return @meta[id.to_sym] if @meta.has_key? id.to_sym
    end

    # The filename of this post without the .post
    def basename
      File.basename(self.file, '.post')
    end
    alias :id :basename

    # The filename without the date aspect
    def slug
      basename.split('_', 2)[1]
    end

    # The filename without the slug aspect
    def filedate
      Date.parse(basename.split('_', 2)[0])
    end

    # Sort by filename
    def <=>(other)
      self.file <=> other.file
    end

    private

    # Takes the images-replaced body and renders markdown
    def markdown
      RDiscount.new(@body).to_html
    end

    # Takes markdown code and highlights code blocks
    def highlight
      markdown.gsub(/<pre><code>:::([-_a-zA-Z0-9]+)\n(.*?)<\/code><\/pre>/m) do |code|
        Uv.parse(@@coder.decode($2), "xhtml", $1, false, 'twilight')
      end
    end
  end
end
