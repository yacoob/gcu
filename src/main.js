// This is the main.js file. Import global CSS and scripts here.
// The Client API can be used here. Learn more: gridsome.org/docs/client-api

import DefaultLayout from '~/layouts/Default.vue'

export default function (Vue, { router, head, isClient }) {

  // Rewrite hash fragment from '#p/NN' to '#photoNN'.
  // Previously GCU allowed using `#p/N` to show Nth photo on the page on load.
  // The hash has been renamed, this handler takes care of old URLs.
  router.beforeResolve((to, from, next) => {
    const reMatch = to.hash.match(/^#p\/(\d+)/);
    if (reMatch) {
      console.log(`redirecting to new anchor format: #photo${reMatch[1]}`);
      next({ path: `${to.path}#photo${reMatch[1]}`, replace: true });
    } else {
      next();
    }
  })

  // Set default layout as a global component
  Vue.component('Layout', DefaultLayout)
}
