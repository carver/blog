# Blog

Personal site built with [Hugo](https://gohugo.io) (extended) and the
[PaperMod](https://github.com/adityatelange/hugo-PaperMod) theme, deployed to
GitHub Pages via GitHub Actions.

## Local development

```sh
hugo server -D
```

`-D` includes draft posts (new posts are drafts by default via the archetype —
flip `draft: false` when a post is ready).

## Writing a post

```sh
hugo new posts/my-post-slug/index.md
```

Using `index.md` inside a directory (rather than `my-post-slug.md`) makes the
post a Hugo **leaf bundle** — see "Images" below.

The `posts` archetype (`archetypes/posts.md`) stamps `date` with the current
time automatically and adds an empty `tags: []` for you to fill in. `date`
is set once, at creation, and is meant to stay put — it's the post's publish
date. `lastmod` is *not* set in front matter at all: it's derived
automatically from git commit history (see below), so editing a published
post and committing the change is all it takes to update its "Updated" date.

## Images

Posts that include images use **page bundles**: the Markdown file is
`content/posts/<slug>/index.md`, and any images for that post live in the
same directory, referenced with plain relative links
(`![alt](my-image.png)`). See `content/posts/hello-world/` for a working
example.

This is the approach used site-wide (as opposed to dropping images in
`static/images/`) because the image travels with the post — no separate
folder to keep in sync, no absolute paths to fix if a post is renamed — and
resources in a bundle are available to Hugo's image-processing pipeline if
this site ever needs resizing/`webp` conversion later. `static/` is reserved
for site-wide files served as-is (favicons, `robots.txt`, etc.), not
per-post assets.

## Dates

- `enableGitInfo: true` (in `hugo.yaml`) lets Hugo read git commit history.
- `frontmatter.lastmod` is configured to prefer the git-derived date
  (`:git`) over any manual `lastmod`/`modified`/`date` front matter field.
- `layouts/_partials/post_meta.html` overrides PaperMod's default post-meta
  partial to show `Published: <date>` always, and `Updated: <lastmod>` only
  when `lastmod` is strictly after `date` — so untouched posts show a single
  date, and edited posts show both.

Because `lastmod` comes from git, it only updates on `hugo build`/`server`
when there's real commit history for the file — a fresh, uncommitted change
won't show as "Updated" until it's committed. The GitHub Actions workflow
fetches full history (`fetch-depth: 0`) for the same reason.

## Theme

- `params.defaultTheme: auto` — dark/light follows the visitor's OS
  preference, with a toggle for the visitor to override. (Note: PaperMod's
  actual config key is `defaultTheme`, not `theme`.)
- Tags are enabled as the site's taxonomy (`taxonomies.tag: tags`), with a
  tag index and per-tag archive pages at `/tags/` and `/tags/<tag>/`.
- RSS is Hugo's default output for the home page and taxonomy pages; nothing
  here disables it.

## Deployment

`.github/workflows/hugo.yaml` builds the site with the extended Hugo binary
(matching the version used locally) and deploys the result to GitHub Pages
via `actions/deploy-pages` on every push to `main`. See the setup notes from
the assistant for the one-time GitHub repo settings step still required.
