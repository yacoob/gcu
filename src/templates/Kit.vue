<template>
  <div>
    <i>{{ $page.kit.id }} </i>
    <h1>
      <Thumb :width="200" :height="200" :photoFile="$page.kit.cover" />
      {{ $page.kit.grade }}:
      {{ $page.kit.title }}
    </h1>
    <ClientOnly>
      <GalleryController
        @gallery-closed="currentPhoto = null"
        @gallery-moved-to="updateCurrentPhoto"
        :images="allPhotos"
        :requestedPhoto="currentPhoto"
      />
    </ClientOnly>
    <div v-for="entry in orderedEntries" :key="entry.date">
      <h2>{{ entry.date }}</h2>
      <Thumb
        v-for="photo in entry.photos"
        :key="photo.href"
        :title="photo.title"
        :photoFile="photo.href"
        @click.native="setCurrentPhoto"
      />
    </div>
  </div>
</template>

<script>
import _ from "lodash";
import Thumb from "~/components/Thumb.vue";

// Redirect '#p/NN' to '#photoNN'.
function _rewriteHash(to, from, next) {
  const reMatch = to.hash.match(/^#p\/(\d+)/);
  if (reMatch) {
    console.log(`redirecting to new anchor format: #photo${reMatch[1]}`);
    next({ path: `${to.path}#photo${reMatch[1]}`, replace: true });
  } else {
    next();
  }
}
export default {
  components: {
    Thumb,
    GalleryController: () => import("~/components/GalleryController.vue"),
  },
  data() {
    return {
      currentPhoto: null,
    };
  },
  // I need to call _rewriteHash in two places: beforeRouteEnter works when this page is
  // loaded from scratch, beforeRouteUpdate works when the hash is updated after
  // page is loaded.
  // https://router.vuejs.org/guide/advanced/navigation-guards.html#the-full-navigation-resolution-flow
  beforeRouteEnter(to, from, next) {
    _rewriteHash(to, from, next);
  },
  beforeRouteUpdate(to, from, next) {
    _rewriteHash(to, from, next);
  },
  methods: {
    // Update currentPhoto from the underlying gallery controller.
    updateCurrentPhoto: function (value) {
      console.log("Kit.vue: updating current photo: " + value);
      this.currentPhoto = value;
    },
    // Brings up gallery displaying a specific photo.
    setCurrentPhoto: function (e) {
      this.currentPhoto = _.map(this.allPhotos, "href").indexOf(
        e.target.dataset.gcuPhoto
      );
    },
  },
  computed: {
    // All entry objects in chronological order.
    orderedEntries: function () {
      return _.orderBy(this.$page.kit.entries, "date");
    },
    // All photo objects across all entries in chronological order.
    allPhotos: function () {
      return _.flatMap(this.orderedEntries, "photos");
    },
  },
  mounted() {
    // Handle url fragment.
    // const dateRe = /#\d\d\d\d-\d\d-\d\d/;
    // const photoRe = /#p\/\d/;
    // const fragment = location.hash;
    // if (dateRe.test(fragment)) {
    //   console.log("it's a date!");
    // } else if (photoRe.test(fragment)) {
    //   console.log("it's a photo number!");
    //   const n = Number(fragment.slice(3));
    //   if (n > 0 && n < this.allPhotos.length) {
    //     // this.currentPhoto = fragment.slice(3);
    //   }
    //   console.log("meh, weird fragment");
    // }
  },
};
</script>

<page-query>
query ($id: ID!) {
  kit(id: $id) {
    id
    title
    grade
    cover
    entries {
      date(format:"YYYY-MM-DD")
      photos {
        title
        href
      }
    }
  }
}
</page-query>