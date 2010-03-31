class Post
  attr_reader :body, :meta, :file

  def self.all
    Dir.glob(File.join('posts','*.post')).map { |p| Post.new(p) }
  end

  def initialize(file)
    @file = file
    File.open(file, 'r') do |file|
      data,body = file.read.split('---', 2).map { |section| section.chomp! }

      @meta = {}
      YAML::load(data).each do |key, val|
        @meta[key.to_sym] = val
      end
      @body = RDiscount.new(body).to_html
    end
  end

  def to_s
    @meta[:title]
  end
end
