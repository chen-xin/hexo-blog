---
title: Create a Hexo theme from scratch 2 - Styling the index page
date: 2018-02-16 21:02:34
categories:
- design
tags:
- hexo
- stylus
- pug
---

In step 1 we created an index page with every required parts, the index page works ugly, now let's make it pretty.
We will use stylus, which is already supported by default.

First, create the *az.styl* file 
===============================

Recall that we already have a stylesheet link refers to '/css/az.css' in out *index.pug* file, it's time to implement it.

First create `~/hexo-blog/themes/az/source/css/az.styl`. With stylus plugin, which was installed by default, Hexo will compile it to *az.css* and save to the public folder, so generated html page can access it via `/css/az.css`. Hexo server will watch and apply changes on any refered style files.

For develop convienent, we should install *hexo-browsersync* plugin for the *hexo-blog* project, so page will be auto reload on any change(excepts \*.pug template change, Hexo server woun't reload them).

Now open the *az.styl*, let's make *header*, *content*, *sider* parts where they should be
==========================================================================================

```stylus
sider-width = 400px
header-height = 200px
base-font = 18px sans-serif

body
  background-color: Cornsilk
  margin: 0
  font: base-font

#header
  background-color: Lightblue
  height: header-height

#content
  margin-right: sider-width
  
#sider
  background-color: Whitesmoke
  position: fixed
  top: 0
  right: 0
  height: 100%
  width: sider-width
```

Here we defined variables `sider-width` and `header-height` to avoid *magic numbers* and easily change them if needed. We also defined the base font for the whole site here.
Adding background-color for each part would help us verify if the parts layout properly, we can remove them later.
We also defined the base font for the whole site here.

Then style the post:
====================


```
.post
  padding: 20px 40px
  .post-header
    background-color: Lightgray
    padding: 10px 20px
    .post-title
      font-size: 2em
      font-weight: bold
    .post-meta
      background-color: Gainsboro
      display: flex
      .post-meta-group
        padding: 0 10px
        a
          padding: 0 5px
  .post-content
    padding: 10px
    h1
      font-size: 1.6em
      line-height: 1em
    h2
      font-size: 1.4em
      line-height: 1em
    h3
      font-size: 1.2em
      line-height: 1em
    h4, h5, h6
      font-size: 1em
      line-height: 1em
```

Then code highlights
====================

We shall try the default *landscape* theme's highlight style: `cp ~/hexo-blog/themes/landscape/source/css/_partial/highlight.styl ~/hexo-blog/themes/Azurewind/source/css/`, then append `@import highlight` to *az.styl*.

Oops, hexo-server complains some missing variables. We have to add the required vars in our *az.styl*, before the `@import highlight` line, I preffered to add them to top of the file:

```
font-mono = mono
font-size = 16px
line-height = 1.8em
```
Syntax highlight still not working. That's because the *highlight.styl* try to highlight `.article-entry`, while our template has only `.post` entry. A easy way to resolve this would be tell *highlight.styl* to fit out template, change the `.article-entry` line to `.article-entry, .post`.

Now we highlight works, but also ugly scrollbars in code block. Styling `.highlight table` to `width: 100%` Resolves this problem.

The sider
===========

```
#sider
  background-color: Whitesmoke
  position: fixed
  top: 0
  right: 0
  height: 100%
  width: sider-width
  .sider
    padding: 10px 20px
    .side-widget
      padding: 10px 0
      .widget-title
        font-size: 1.2em
        font-weight: bold
        border-bottom: inset

      .side-widget-topnav
        display: flex
        justify-content: space-around
        height: 2em
        a
          display: inline-block
          text-align: center
          flex-grow: 1
          &:hover
            text-decoration: none
            border-bottom: inset

      .side-widget-search
        input#search-site
          width: 100%
          box-sizing: border-box
          
      span[class$="list-count"]
        &:before
          content: ' ('
        &:after
          content: ')'

      ul
        list-style-type: none
        margin: 0
        padding: 0

      ul.category-list, ul.archive
        ul
          padding-left: 1em

      ul.tag-list
        display: flex
        flex-wrap: wrap
        li
          margin: 2px 10px 2px 0
```
We use pseudo element to add braces to post count in archive, tag and category lists.
The tag list was displayed as cloud. We don't use Hexo's tag-cloud helper here because it dosen't have post count property.


The result
==========

Now the index page looks like a blog, and the category, tag and archive links works. Thou still ugly to the critics.
We sudpend refining the index page for now, and move on to the post view.

