## File layout

Each grade is a top level zola section. Each kit is a subsection in a grade.
Each entry (a batch of photos for a given kit) is a zola page in that
subsection. Pages for entries are rendered to empty files, then removed together
with their parent directories after `zola build` in the Makefile.

## Example page content

```
+++
date = 2123-12-01

[extra]
cover = "gcu-00000.jpg"
photos = [
{ href = "gcu-00000.jpg", title = "Here we go!" },
...
]
+++
```

## Templates

All of the templates have:
```jinja
{# vim: set tw=0 ft=jinja: #}
```
in their first line; `vim` is auto-setting `html+jinja` filetype and `ale` is
more than happy to wreck the formatting on save. `{%- foo %}` is preferred for
whitespace control.

* `base.html`: base for almost all other templates, has configurable `page_vars`
  section, and an optional context dump.
* `macros.html`: snippets reusable elsewhere.
* `empty.html`: empty template, used for bottom-most pages.
* `everything.html`: `/everything` page with all of the kits.
* `grade.html`: page with all of the kits from given grade.
* `index.html`: main page; enumerates all pages (slow), sorts by date, then
  dedups recent entries for the same kit (to avoid having >1 entry for the same
  kit).
* `kit.html`: single kit; enumerates all kits for same grade, then loops through
  them until it finds itself in order to establish prev/next.
* `rss.xml`: feed of the latest entries.
* `sitemap.xml`: sitemap; iterates over its own `entries` struct, a dirty trick
  is used to work out `lastmod` for a kit.
* `404.html`: 404 handler.
