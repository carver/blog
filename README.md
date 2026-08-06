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

## Post previews

Opening a pull request publishes a preview of the site — drafts included — to
a throwaway URL that can be shared with people who don't have a GitHub
account. Push a branch, open a PR, and the Cloudflare Pages check run on the
PR links to a URL like `https://a1b2c3d4.blog-preview.pages.dev`. It rebuilds
on every push to the branch and is deleted when the project is.

Previews are built by Cloudflare rather than by a GitHub Actions workflow,
which keeps GitHub Pages free for production: **a repository only gets one
Pages deployment**, so a preview built through `actions/deploy-pages` would
overwrite the live site.

### Why this can't be triggered by someone else

Cloudflare's GitHub App does not create previews for pull requests opened
from forks — only for branches pushed to this repository, which nobody else
can write to. That is a property of the integration, not a rule configured
here, so there is no `if:` guard to keep in sync and no build minutes burned
by a stranger's PR.

### What the build does differently from production

`scripts/cf-pages-build.sh` is the build command. Compared to the production
workflow it:

- builds drafts and future-dated posts (`--buildDrafts --buildFuture`) — the
  archetype marks new posts `draft: true`, so without this a preview of a
  work-in-progress post would be an empty site;
- sets `--baseURL` to match Cloudflare' target domain, so stylesheets and
  internal links resolve against the preview host instead of pointing back at
  `carver.github.io`;
- runs in the `preview` environment and overrides `params.env`, because
  PaperMod emits `<meta name="robots" content="index, follow">` when *either*
  `hugo.IsProduction` or `site.Params.env == "production"` is true — both have
  to be off for the tag to flip to `noindex`;
- writes a `_headers` file (`X-Robots-Tag: noindex, nofollow`) and a
  disallow-everything `robots.txt` into `public/`, so an unfinished post can't
  turn up in search results or compete with the real site.

It also runs `git submodule update --init` when `themes/PaperMod` is missing:
Cloudflare's checkout does not initialise submodules, and the resulting Hugo
error doesn't mention the theme.

To test the exact preview build locally:

```sh
WORKERS_CI_BRANCH=local PREVIEW_DOMAIN="host:1313" ./scripts/cf-pages-build.sh
```

### One-time Cloudflare setup

1. At <https://dash.cloudflare.com> → **Workers & Pages** → **Create** →
   **Pages** → **Connect to Git**, authorise the Cloudflare GitHub App for
   *only* the `carver/blog` repository and select it.
2. Name the project `blog-preview` (this becomes the `*.pages.dev` hostname).
3. Build settings:
   - Build command: ./scripts/cf-pages-build.sh
   - Version command: npx wrangler versions deploy
   - Deploy command: ls
   The deploy command is a no-op because we are only interested in the preview
   builds for now. If you want to do production builds, use `npx wrangler deploy`.
4. Add an environment variable `HUGO_VERSION` = `0.164.0`, matching
   `HUGO_VERSION` in `.github/workflows/hugo.yaml`. Without it Cloudflare
   picks its own default. Keep the two in sync on Hugo upgrades. (The theme
   uses no SCSS, so the non-extended binary Cloudflare may install is fine.)
4. Add an environment variable that matches the domain you were assigned by
   Cloudflare. Set `PREVIEW_DOMAIN` to something like
   `-blog-preview.a1b2c3.workers.dev` (the actual domain will be shown in the
   Cloudflare dashboard under **Domains**). **Note the leading dash!**
5. Under **Settings → Build → Branch Control**, check to enable **Builds for
   non-production branches: Enabled**. This way Cloudflare will build versions
   of the site tied to every branch push.
