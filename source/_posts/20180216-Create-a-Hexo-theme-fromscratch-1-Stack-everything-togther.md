---
title: Create a Hexo theme from scratch 1 - Stack everything together
date: 2018-02-16 02:40:32
categories:
- design
tags:
- hexo
- stylus
- pug
---

A few days ago the idea of making my own blog hit me. After some investigation, I decided to start from Hexo, a static blog generator with plenty of plugin and themes.
There are lots of cool themes already, some actully meet my needs, but the idea of creating my cool theme hit me harder.
I expected to finish the theme job within a couple of hours, and time laughed at the arrogent newbie.

Step0: Prepare
==============


1. Install Hexo with the default "landscape" theme, create some posts to feel if you like it.
1. Read the Hexo docs on theme, template, variables and helpers.
2. Inspect some published themes, try to figure out how they works.
3. Pick template language. For it is the year of pug of Chinese luna calendar, pug it is.
4. Prepare project structure(suppose Hexo installed to *~/hexo-blog*), and configure theme to 'AzureWind':

> At the very least, a theme should contain an index template.

```bash
cd ~/hexo-blog/themes
mkdir AzureWind
cd AzureWind
touch _config.yml
mkdir -p languages layout # scripts source/css source/js source/img
cd layout
touch index.pug # layout.pug archive.pug category.pug tag.pug post.pug page.pug
git init
```

Step1: Stack everything together
==============================
> TARGET: Create the index view, with every thing we want in it.

First the pug template skeleton:
-------------------------------

```pug
doctype html
html
  head
    meta(http-equiv="content-type" content="text/html; charset=utf-8")
    meta(name="viewport" content="width=device-width, initial-scale=1.0")
    meta(name="description" content=config.description)
    link(rel="stylesheet" type="text/css" href="/css/az.css")
body
```
The second *meta* line is required for responsive design ,which will auto layout for mobile and desktop. We shall implement that later, for now, just leave it here.
The third *meta* line was description about our blog, which retrieved from Hexo configure.
We shall definatly have some styles, so put the style sheet link here.

Then we define what should appear on our index view:
----------------------------------------------------

- A header part, with background image and some text, maybe blog title, brieves,  etc.
- The content part, which hold posts, with the following components within each post:
  - post header
    - title
    - post date
    - tags
  - the post content
  - post footer
- The sider bar, with the following components:
  - Home, RSS and About button
  - search bar
  - site categories
  - site tags

Let's create the *header*, *content* and *sider* part, and define css classes for each components:

``` pug
doctype html
html
  head
    meta(http-equiv="content-type" content="text/html; charset=utf-8")
    meta(name="viewport" content="width=device-width, initial-scale=1.0")
    meta(name="description" content=config.description)
    link(rel="stylesheet" type="text/css" href="/css/az.css")
  body
    #header
      .site-title
        != config.title
      .site-subtitle
        != config.subtitle

    #content
      for post in page.posts.toArray()
        .post
          .post-header
            .post-title
              a.title(href=url_for(post.path))
                != post.title
            .post-meta
              .post-meta-group
                != full_date(post.date)
              .post-meta-group
                for tag in post.tags.toArray()
                  a(href=url_for(tag.path))= tag.name
          .post-content
            if post.excerpt
              != post.excerpt
            else
              != post.content
          .post-footer <---------->
        hr

    #sider
      .side-widget
        .side-widget-topnav
          a(href=url_for(config.root)) Home
          a(href=url_for(theme.about)) About
          a(href=url_for(theme.rss)) RSS

      .side-widget
        .side-widget-search
          input#search-site(placeholder="Search...")

      if site.categories.length
        .side-widget
          .side-widget-list
            h3.widget-title #{ __('categories') }
            .widget
              != list_categories({show_count: true})

      if site.tags.length
        .side-widget
          .side-widget-list
            h3.widget-title #{ __('tags') }
            .widget
              != list_tags({show_count: true})

      .side-widget
        .side-widget-list
          h3.widget-title #{ __('archives') }
          .widget
            != list_archives({show_count: true})

```

Please note how to get post variables via `for post in page.posts.toArray()`, and same as tags.
And note that the 'About' and 'RSS' page should be defined in theme configure. In our case, it would be *~/hexo-blog/themes/AzureWind/_config.yml*.
We add hyperlink to post in title so we don't need the *more..* button.
With full_date() Hexo helper we get date and time formated as what defined in site's *_config.yml*.
The `__('categories')` is for internationalization, that will be discussed later.
For all 3 primary parts(*header*, *content*, *sider*), we also create a div to wrap all the content, so we can the padding, margin, border for it without intersecting other parts.11

Restart Hexo server to see the result
-------------------------------------

*note*: While styles(\*.css, \*,styl, etc) will be automatic applied on change by Hexo server, templates(our *.pug) files sometimes won't, we have to manully restart to see template changes. That's why we put everything together first!

The page looks awful, all parts flow from top to bottom, post title looked same as normal text, no code highlight. We can just inspect to assure every part id and css class names correctly applied. In the next step, let's add some style to it.  
