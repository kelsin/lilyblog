require 'grepper'
require 'htmlentities'

class Post
  attr_reader :meta, :file

  @@coder = HTMLEntities.new

  def self.page_size=(size)
    @@page_size = size
  end

  def self.files(tag = nil)
    if tag
      g = Grepper.new
      g.pattern = /^tags:.*#{tag}/
      g.files = files
      g.run

      files = []

      g.results.each do |file, matches|
        files << file if matches.size > 0
      end

      files
    else
      Dir.glob(File.join('posts','*.post')).sort.reverse
    end
  end

  def self.limit(page)
    offset = (page - 1) * @@page_size
    offset..(offset + (@@page_size - 1))
  end

  # Returns all of the posts
  def self.all(page = 1)
    files[limit(page)].map { |p| Post.new(p) }
  end

  # Total number of posts
  def self.count(tag = nil)
    files(tag).size
  end

  # Returns all of the posts with a certain tag
  def self.find_by_tag(tag, page = 1)
    files(tag)[limit(page)].map { |p| Post.new(p) }
  end

  def self.search(string, page = 1)
    g = Grepper.new
    g.pattern = /#{string}/i
    g.files = files
    g.run

    files = []

    g.results.each do |file, matches|
      files << file if matches.size > 0
    end

    files.sort.reverse.map { |p| Post.new(p) }
  end

  def self.find(name)
    Post.new(File.join('posts',"#{name}.post"))
  end

  def self.tag(tag)
    self.tags[tag].to_f / number_of_tags
  end

  def self.tags
    return @counts if @counts

    @counts = {}

    files.map do |file|
      Post.new(file).tags.each do |tag|
        @counts[tag] ||= 0
        @counts[tag] += 1
      end
    end

    return @counts
  end

  def self.number_of_tags
    total = 0

    self.tags.each do |tag, amount|
      total += amount
    end

    return total.to_f
  end

  def self.clean_tag(tag)
    tag.strip.gsub(/[^0-9a-zA-Z_-]+/, '_').downcase
  end

  def initialize(file)
    @file = file
    File.open(file, 'r') do |file|
      data,@body = file.read.split(/\n(---)?\n/, 2)

      @meta = {}
      YAML::load(data).each do |key, val|
        @meta[key.to_sym] = val
      end
    end
  end

  # Runs the body of the post through RDiscount and returns the html
  def body(format = nil)
    return @body if format == :raw

    RDiscount.new(@body).to_html.gsub(/<pre><code>:::([-_a-zA-Z0-9]+)\n(.*?)<\/code><\/pre>/m) do |code|
      Uv.parse(@@coder.decode($2), "xhtml", $1, false, 'twilight')
    end
  end

  # The filename (without the .post) of this post
  def id
    basename
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
    raise NoMethodError
  end

  # The filename of this post without the .post
  def basename
    File.basename(self.file, '.post')
  end

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
    self.basename <=> other.basename
  end
end
