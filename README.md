[![Netlify Status](https://api.netlify.com/api/v1/badges/39fb5576-3cb9-4a94-b61c-4e9eb0fd9108/deploy-status)](https://app.netlify.com/sites/gcu/deploys)

# GCU Tactical Grace

## Pages clasification

| description | url              |                     data needed | structure | ready |
| :---------- | :--------------- | ------------------------------: | :-------: | :---: |
| kit page    | `/:grade/:title` |                single kit entry |     ✔️     |   ❌️   |
| grade page  | `/:grade`        |          all kits of that grade |     ✔️     |   ❌   |
| all kits    | `/everything`    | all kits with grade information |     ✔️     |   ❌   |
| main page   | `/`              |                3 newest entries |     ✔️     |   ❌   |
| rss         | `/rss.xml`       |               15 newest entries |     ❌     |   ❌   |
| 404 page    |                  |                              :3 |     ❌     |   ❌   |
| sitemap     | `/sitemap.xml`   |                          plugin |     ❌     |   ❌   |

## The road to avuesome site
* fix gallerycontroller reuse, check for hashcontroller behaviour in the same situation
* get rid of lodash, or play with webpack and see if that import can be shaven down to that one function
* clean up the header and meta files
* basic look using bootstrap@3 or tailwind plugin
  * font from npm instead of google fonts https://gridsome.org/docs/assets-fonts/
  * icon for youtube thumbs from fontawesome? https://gridsome.org/docs/assets-svg/
* bring back some convenience functions in a form of a Makefile
  * or move it to js scripts? 😼

## Further improvements
* consider replacing pregenerated thumbnails by netlify's transforms
  * would need to add a live smartcropper for `gridsome develop` server:
  * https://gridsome.org/docs/server-api/#apiconfigureserverfn
* check out whether netlifycms will work for gcu
* test page transitions
* consider algolia

## Note on vscode/browser debugger
- wsl AND container is probably an extra complication matter here
- all of the breakpoints I'd set in vscode would become "unbound" that is, vscode wouldn't be able to map them to the src code the browser serves
- firefox wouldn't launch from wsl, attach would work, but I'd only get browser console output in vscode's debug console
  - for extra aggravation points, FF asks for permission on remote debugger connecting and the pop up doesn't always pop to the top, silently waiting in the background under the editor instead :(
- chrome would launch - and it kind of makes sense to use it, to separate it from FF which I use for normal browsing and connect
- neither of the browsers would break on load or honor the breakpoints set in vscode
- `webpack` section in the dev tools is rather messy, need to read about it and `source-maps`
- calling `debugger` from the code worked, *and* it actually pass the control to vscode
  - actually, both in-chrome debugger and in-vscode debugger would work in sync
- tl;dr: more testing (heh) needed
