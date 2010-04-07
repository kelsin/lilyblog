# Add lib directory to load path
LILYBLOG_ROOT = File.dirname(__FILE__)
$:.unshift "#{LILYBLOG_ROOT}/lib"

# LilyBlog files
require 'lilyblog/post'
require 'lilyblog/helpers'

desc "List all Posts"
task :posts do
  LilyBlog::Post.all.reverse.each do |post|
    puts "#{post.filedate.strftime('%Y/%m/%d')} - #{post}"
  end
end

desc "List all Tags"
task :tags do
  LilyBlog::Post.tags.sort do |a,b|
    a[0].to_s <=> b[0].to_s
  end.each do |tag|
    puts "#{tag[0]} - #{tag[1]}"
  end
end

desc "List all Urls"
task :urls do
  LilyBlog::Post.all.reverse.each do |post|
    puts "/#{post.filedate.strftime('%y/%m/%d')}/#{post.slug}"
  end
end

desc "Creates posts from Wordpress DB"
namespace :import do
  task :wordpress do
    import_requires

    raise "Please specify a database in the DATABASE environment variable" unless ENV['DATABASE']
    DB = Sequel.connect(ENV['DATABASE'])
    Sequel::MySQL.convert_invalid_date_time = nil

    wp_posts = DB[:wp_posts]
    rels = DB[:wp_term_relationships]
    taxes = DB[:wp_term_taxonomy]
    terms = DB[:wp_terms]

    wp_posts.filter(:post_type => 'post').all do |post|
      id = post[:ID]

      # First check for later revisions
      content = wp_posts.filter(:post_type => 'revision', :post_parent => id).order(:ID).last || post

      date = content[:post_date]
      slug = post[:post_name]
      body = content[:post_content]

      tags = []
      # Get tags
      rels.filter(:object_id => id).all do |rel|
        taxes.filter(:term_taxonomy_id => rel[:term_taxonomy_id], :taxonomy => 'post_tag').all do |tax|
          terms.filter(:term_id => tax[:term_id]).all do |term|
            tags << term[:slug]
          end
        end
      end

      meta = {
        'title' => content[:post_title].to_s,
        'date' => content[:post_date],
        'tags' => tags.join(', ') }

      yaml = YAML::dump(meta).gsub(/^---/, '').strip

      file = File.join(File.dirname(__FILE__), 'posts', "#{'%02d' % date.year}#{'%02d' % date.month}#{'%02d' % date.day}_#{slug}.post")

      # Check if file exists
      raise "File already exists: #{file}" if File.exists? file

      File.open(file, 'w') do |output|
        output.write("#{yaml}\n---\n#{body}")
      end
    end
  end
end

def import_requires
  require 'rubygems'
  require 'sequel'
  require 'yaml'
  require 'rdiscount'
end
