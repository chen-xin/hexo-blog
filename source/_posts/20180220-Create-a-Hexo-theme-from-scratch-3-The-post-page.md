---
title: Create a Hexo theme from scratch 3-The post page
date: 2018-02-20 00:18:59
categories:
- design
tags:
- hexo
- stylus
- pug
---
The post view and the index view are rather similer. We first make copy of our *index.pug* and name it *post.pug*, then make 2 modifications:


First the content part, we have only one post to deal with, and all the post variables now become page variables, we shall modify our content to fit that:
```
    #content
      .content
        .post
          .post-header
            .post-title
              a.title(href=url_for(page.path))
                != page.title
            .post-meta
              .post-meta-group
                != full_date(page.date)
              .post-meta-group
                for tag in page.tags.toArray()
                  a(href=url_for(tag.path))= tag.name
          .post-content
            != page.content
          .post-footer <---------->
```

Second we add a *toc* widget to show post tocs:
```
        .side-widget
          .side-widget-toc
            .widget-title #{ __('toc') }
            .widget
              != toc(page.content, {list_number: true})
```

We love copy and paste, but once we want change someting in common, it's not cool updating many times. Let's put the common parts together:

create a *layout.pug*, put common parts in, and leave the special parts as *block*:

Then we shall see that the `.post` part of the index view and the post view are also similer, we can create pug mixin to deal with them:

```
mixin post_mixin(post)
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

```
Now our index.pug becomes:
```
extends _layout.pug
include _post.pug

block content
  for post in page.posts.toArray()
    +post_mixin(post)
```

And post.pug becomes:
```
extends _layout.pug
include _post.pug

block content
  +post_mixin(page)

block side-toc
  .side-widget
    .side-widget-toc
      .widget-title #{ __('toc') }
      .widget
        != toc(page.content, {list_number: true})

```
You may already noticed that the *toc* widget displaies 2 sets of number, and indent too much between levels. We shall style them like categories:

```
      ul, ol
        list-style-type: none
        margin: 0
        padding: 0

      ul.category-list, ul.archive, ol
        ul, ol
        padding-left: 1em
```

