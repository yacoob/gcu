[![Netlify Status](https://api.netlify.com/api/v1/badges/39fb5576-3cb9-4a94-b61c-4e9eb0fd9108/deploy-status)](https://app.netlify.com/sites/gcu/deploys)

# The road to avuesome site
* convert data to yaml
* write down scenarios for data access, decide whether grade as a separate type is needed
* add global metadata with sorted entries (needed for main/rss)
* add prev/next links on the kit page
* handle url fragment on kit page load - both `#YYYY-MM-DD` and `#p/1`
  * do I want to simplify `#p/1` into just `#1`? probably not.
  * check out lightgallery's hash plugin
  * decide whether I want to keep pushing new slides to `history` - it
    is nice, but spams the entries
* add a component that creates a clickable image that links to a specific kit (and maybe entry)
* grade page
* set up a debugger
  * https://vuejs.org/v2/cookbook/debugging-in-vscode.html
* `/everything` page - sort by grade, then title
* main page - 3 newest entries
* rss "page" - 15 newest entries
* 404 page
* sitemap - https://gridsome.org/plugins/@gridsome/plugin-sitemap
* get rid of lodash, or play with webpack and see if that import can be shaven down to that one function
* clean up the header and meta files
* basic look using bootstrap@3 or tailwind plugin
  * font from npm instead of google fonts https://gridsome.org/docs/assets-fonts/
  * icon for youtube thumbs from fontawesome? https://gridsome.org/docs/assets-svg/

# Further improvements
* consider replacing pregenerated thumbnails by netlify's transforms
  * I need to see the actual smartcropped images during development/preview,
    either images go in first or I grow my own smartscaler that does the same as
    netlify
* check out whether netlifycms will work for gcu
* test page transitions
* consider algolia
