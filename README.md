# Lilyblog

Hey, this is a tiny blog engine inspired by
[Markley](http://www.restafari.org/introducing-marley.html) and
[Toto](http://github.com/cloudhead/toto). This blog is meant to be hosted in a
git repository and served by a web stack with heavy http caching. It was written
in order to be deployed on [Heroku](http://heroku.com/). Heroku allows you to
push your git repo in order to deploy, handles rack apps, and includes varnish
in it's stack to handle HTTP caching properly.

## Features

I used to host my blog via wordpress and decided I wanted something simpler. I
didn't need many of the features and didn't want to edit posts out of emacs
anymore. No need to have dynamic code on the page.

### Plain text posts

Posts are just flat text files with a YAML section at the top and a Markdown
section beneath. More on the post format below.

### Tags

One of the few features I can't live without is tagging. I don't care about
categories (I had them in the first draft, but quickly removed them since I
don't care about them). Tags are just put into the metadata for the post, and
while viewing posts by tags we use a ruby grepping library to find the proper
posts.

### Search

This is basically the same code as tags, but we search for any file including
the word (could be the title, tag or body text). This was almost no code to
implement but does help me find post quickly. Also allows someone to subscribe
to my site without using a tag I've defined in my post.

### Feeds

There is a main blog feed, a feed for any tag, and a feed for any search
term. They are accessible at `/feed/`, `/tags/[tag]/feed/`, and
`/search/[search]/feed/`. They should be auto discovered by your browser if you
are viewing the proper page as well. These feeds are in rss 2.0 format.

### Highlighting

Code highlighting is handled by Ultraviolet in the same format that is used by
the Codehighlighter rack plugin. I wasn't able to actually use the rack plugin
and decided to just put the code into my post model. I didn't need many of the
features of the rack plugin, but it is awesome and I recommend it for anyone
working with a rack app that wants to take advantage of code highlighting.

### Disqus

I decided to use Disqus for comments. I spent a while thinking about pros and
cons to the different comment systems, or just coding my own (Probably including
a database). I decided that the extra code / effort wasn't worth it since the
end result would have less features. Hopefully Disqus allows people to comment
easier (OpenID and other login options) while still allowing my pages to be
completely un-dynamic.

### Standards

The blog validates as XHTML 1.0 Strict and includes some helpful sitemap and
robots routes that will help keep your blog indexed and working across browsers.

### Emacs helpers.

I include some emacs helpers that will help you create a new post and stuff like
that. These aren't included in the slug if you push to Heroku.

## Post Format

Posts are placed in the `/posts/` directory and have a special filename that
functions as the slug for the post.

    20100402_example-first-post.post

The first part is the date of the post (sortable), followed by an underscore
(`_`) and then the slug of the post. This post is accesible at the following url:

    /2010/04/02/example-first-post

The displayed title of this post does not need to match this slug at all (my
included emacs helpers keep them synced up however).

Only files with an extension of `.post` are used so you can make drafts just by
saving them as .draft (as my emacs modes expect) or anything else you want.

The top of the post file is a yaml segment with metadata. This segment runs
until the first blank line. Following that is the markdown post. For example:

    title: First Post
    tags: hello, example-tag
    date: 2010-04-02 1:45am

    I love making posts using markdown!

    * Lists
    * are
    * easy

        :::ruby
        def example_ruby(code)
            "is easy too!"
        end

    ##### Headers

    Using H5 headers helps keep things cleaned, but this is up to you and your
    css you create for the blog.

Once you create a post file it will be displayed by the site. Normally you want
to connect git pushes to the clearing of your http cache so that all tag info is
recreated.

I only designed this blog to use those 3 yaml attributes but you can put as much
yaml as you want as long as there is not an empty line included. Any yaml
attribute is available on the model in two ways. For example if your post has
this header:

    title: Music Posting
    music: Kate Nash - Mariella
    date: Febuary 4th

You can access this attribute in the view code as:

    # The long method
    @post.meta['music']

    # The short method
    @post.music

The `method_missing` method on Post looks up that attribute in the @meta
attribute returning `MethodMissing` if it's not found. This means that if only
some posts have an attribute either use the `.meta` example or catch the
exception.

## View Files

I use haml as a template engine but it's easy to replace since sinatra supports
all of the major ones.

### layout.haml

This is the main layout file displayed on every page (except feeds). Edit this
to add new features to every page.

### feed.builder

The builder template file that handles formatting the feeds. Edit this if you
want to change the feed format.

### posts.haml

This is the file that displays a list of posts. This is used on every page that
isn't feeds or a single post page.

### _post.haml

This is the main file to display a single post. It expects a variable `comments`
to be true or false. It's true on single post pages and false on list pages. I
like display the full blog post on the main listing pages.

### Inline Templates

Technically the main template for a single post page ONLY calls the _post.haml
partial. Since it's a one line template I include it inline. You can delete it
from `blog.rb` and add a new `post.haml` in the view directory if you want to
customize it any more.

## Emacs Helpers

My emacs file can easily be added to your config by putting it in your load page
and adding this to your emacs config:

    ;; Blog helpers
    (require 'blog)

It will auto load when you need it. You call the `blog-create-post` function to
create a post. `blog-open-post` to edit one.

### Editing posts

The editing mode is a mode inherited from `markdown.el`.
