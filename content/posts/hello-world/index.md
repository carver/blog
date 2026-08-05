---
date: '2026-08-05T09:00:00-07:00'
draft: false
title: 'Hello, World'
tags: ['meta', 'hugo']
---

This is the first post on this blog, mostly here to prove the setup works end to end: [PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, dark mode that follows your system preference, tags, and git-derived "last updated" timestamps.

## Why a page bundle

This post lives at `content/posts/hello-world/index.md` instead of a bare `content/posts/hello-world.md`. That makes it a Hugo **leaf bundle** — the post and any images it uses sit together in the same directory:

```
content/posts/hello-world/
├── index.md
└── mountains.png
```

The image below is referenced with an ordinary relative Markdown link:

```markdown
![A gradient placeholder image](mountains.png)
```

![A gradient placeholder image](mountains.png)

Page bundles are the recommended way to inline images in Hugo posts because:

- the image travels with the post — copy or move the directory and nothing breaks
- relative links (`mountains.png`, not `/images/mountains.png`) work the same in every post, with no manual path bookkeeping
- resources in the bundle are available to Hugo's image-processing pipeline (`.Resources.Get`, resizing, `webp` conversion, etc.) if this site ever needs that later
- it keeps images out of `static/`, which is meant for files served as-is at a fixed site-wide path (favicons, robots.txt, and the like) rather than per-post assets

## Some more text, to show off the theme

Here's a second paragraph just to give the theme something to lay out: line height, link color (like this [link to Hugo](https://gohugo.io)), and paragraph spacing in both light and dark mode.

### A subheading

- bullet one
- bullet two
- bullet three

> A blockquote, to check that PaperMod's styling looks right here too.

```go
func main() {
    fmt.Println("hello from a fenced code block")
}
```

That's it — just enough content to confirm headings, lists, quotes, code blocks, and an inline image all render the way they should.
