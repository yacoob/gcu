[![Netlify Status](https://api.netlify.com/api/v1/badges/39fb5576-3cb9-4a94-b61c-4e9eb0fd9108/deploy-status)](https://app.netlify.com/sites/gcu/deploys)

# GCU has following dependencies

* [Bootstrap](http://getbootstrap.com/)
* [lightgallery](https://github.com/sachinchoolur/lightGallery.js)


## Zola migration next TODO
* check `|safe` markings
* work out whitespace control
* verify whether all macros are needed
* rss
* sitemap.xml that excludes the leaf files
* make a decision about the switch
* document the templates


## TODO

* consider having two set of thumbs; the gallery ones don't
  get larger than 165x165 so with current 400x400 thumbs >75% of the image
  "bulk" is wasted anyway
* verify netlify caching headers
* get rid of the bootstrap
