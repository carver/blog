#!/usr/bin/env bash
#
# Build command for Cloudflare Pages preview deployments.
#
# Production still deploys to GitHub Pages via .github/workflows/hugo.yaml —
# this script only ever runs on Cloudflare, and everything Cloudflare serves is
# a preview. That is why it unconditionally builds drafts and marks the output
# noindex: there is no "production" case to branch on here.
#
# See the "Post previews" section of README.md for the dashboard settings this
# expects.

set -euo pipefail

THEME_DIR="themes/PaperMod"

# The theme is a git submodule. Cloudflare's build clone does not initialise
# submodules, so without this Hugo fails with a bare "module not found" that
# gives no hint about the real cause.
if [ ! -f "$THEME_DIR/theme.toml" ]; then
  echo "==> $THEME_DIR is empty; initialising submodule"
  git submodule update --init --recursive
fi

# Build the url for the preview site using the branch name and the Cloudflare domain.
# First, check that the branch name is available.
if [ -z "${WORKERS_CI_BRANCH:-}" ]; then
  echo "WORKERS_CI_BRANCH is unset — this script is meant to run in a Cloudflare Workers build." >&2
  exit 1
fi
# Next, check that the rest of the domain is set in Cloudflare.
# PRODUCTION_DOMAIN is the domain name of the production site, e.g. "blog-preview.a1b2c3.pages.dev".
if [ -z "${PRODUCTION_DOMAIN:-}" ]; then
  echo "PRODUCTION_DOMAIN is unset — You must manually set this variable in the Cloudflare Workers build." >&2
  exit 1
fi
# CF_PAGES_URL is the unique per-deployment URL Cloudflare injects, e.g.
# https://branch-name-blog-preview.a1b2c3.pages.dev — the same URL the GitHub check run
# links to. Hugo needs it as baseURL or every stylesheet and internal link in
# the preview points back at the production GitHub Pages site.
CF_PAGES_URL="https://${WORKERS_CI_BRANCH}-${PRODUCTION_DOMAIN}"

echo "==> Building preview for branch '${WORKERS_CI_BRANCH:-unknown}' at $CF_PAGES_URL"

# -D and -F are the whole point of a preview: posts start life as drafts (see
# archetypes/posts.md) and would otherwise build to an empty site. --gc and
# --minify match the production build so previews reflect what will ship.
#
# The environment is deliberately *not* production. PaperMod's head partial
# emits <meta name="robots" content="index, follow"> when either
# `hugo.IsProduction` or `site.Params.env == "production"` holds, so both have
# to be flipped for previews to carry a noindex meta tag that agrees with the
# _headers file written below. HUGO_PARAMS_ENV overrides the `params.env`
# value set in hugo.yaml.
HUGO_PARAMS_ENV=preview hugo \
  --environment preview \
  --gc \
  --minify \
  --buildDrafts \
  --buildFuture \
  --baseURL "$CF_PAGES_URL/"

# Keep previews out of search results. Drafts are unfinished writing, and a
# second crawlable copy of the site would compete with the real one. Both files
# are written after the build so they land in the published output directory:
# _headers is Cloudflare's per-response header config, and robots.txt overwrites
# the permissive one Hugo generates from enableRobotsTXT.
cat > public/_headers <<'EOF'
/*
  X-Robots-Tag: noindex, nofollow
EOF

cat > public/robots.txt <<'EOF'
User-agent: *
Disallow: /
EOF

echo "==> Preview build complete"
