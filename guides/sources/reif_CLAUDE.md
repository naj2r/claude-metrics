# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is Julian Reif's personal academic website built with Jekyll using the [Minimal Mistakes](https://github.com/mmistakes/minimal-mistakes) theme as a remote theme. The site is hosted on GitHub Pages at julianreif.com.

## Build and Deploy Commands

Build locally:
```bash
bundle exec jekyll build
```

Serve locally with live reload:
```bash
bundle exec jekyll serve
```

Note: Changes to `_config.yml` require restarting the server.

**Deploy process (manual):**
1. Run `bundle exec jekyll build`
2. Copy contents of `_site/` to root folder
3. Copy `CNAME` to root folder

## Architecture

### Data-Driven Content
Research publications and software listings are managed via JSON data files in `_data/`:
- `publications.json` - Published papers
- `publications-working.json` - Working papers
- `publications-chapters.json` - Book chapters
- `publications-other.json` - Other publications
- `publications-grants.json` - External grants
- `software.json` - Software package descriptions

The `_pages/research.md` template iterates over these JSON files to render the research page dynamically.

### Theme Customizations
Custom overrides to the Minimal Mistakes theme:
- `/assets/css/main.scss` - Removes hyperlink underlines, larger avatar, no sidebar fade
- `/_includes/footer.html` - RSS feed link removed
- `/_includes/head/custom.html` - Favicon, syntax highlighting (VS Code Light+), Font Awesome 6.5.2, Google Analytics

### Key Configuration
- Theme skin: `contrast`
- Remote theme: `mmistakes/minimal-mistakes`
- Navigation defined in `_data/navigation.yml`

## Content Updates

To add a new publication, add an entry to the appropriate JSON file in `_data/`. Each entry supports fields: `title`, `coauthors`, `publication`, `award`, `media`, `policy`, `other`, `abstract`.

Research PDFs are stored in `/research/` and CV in `/cv/`.
