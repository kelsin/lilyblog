class Post
  attr_reader :body, :meta, :file

  def self.all
    Dir.glob(File.join('posts','*.post')).map { |p| Post.new(p) }
  end

  def self.find(id)
    Post.new(File.join('posts',"#{id}.post"))
  end

  def self.find_by_tag(tag)
    Post.all.select do |post|
      post.tags.member? tag
    end
  end

  def self.tag(tag)
    self.tags[tag].to_f / number_of_tags
  end

  def self.tags
    return @counts if @counts

    @counts = {}

    Post.all.map do |p|
      p.tags.each do |tag|
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
    tag.strip.gsub(/[^0-9a-zA-Z_]+/, '_').downcase.to_sym
  end

  def initialize(file)
    @file = file
    File.open(file, 'r') do |file|
      data,body = file.read.split('---', 2).map { |section| section.strip }

      @meta = {}
      YAML::load(data).each do |key, val|
        @meta[key.to_sym] = val
      end
      @body = RDiscount.new(body).to_html
    end
  end

  def id
    File.basename @file, '.post'
  end

  def date
    Time.parse(@meta[:date])
  end

  def to_s
    @meta[:title]
  end

  def tags
    @meta[:tags].split(',').map do |tag|
      Post.clean_tag(tag)
    end
  end

  def method_missing(id, *args)
    return @meta[id.to_sym] if @meta.has_key? id.to_sym
    raise NoMethodError
  end

  private

end
