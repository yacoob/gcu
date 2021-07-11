<template>
  <div>
    <i>{{ $page.kit.id }} </i>
    <h1>
      <Thumb :width="200" :height="200" :photoFile="$page.kit.cover" />
      {{ $page.kit.grade }}:
      {{ $page.kit.title }}
    </h1>
    <HashController :currentPhoto="currentPhoto" />
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
        :id="'photo' + getGalleryIdx(photo.href)"
        @click.native="photoClicked"
      />
    </div>
  </div>
</template>

<script>
import _ from "lodash";
import Thumb from "~/components/Thumb.vue";
import HashController from "~/components/HashController.vue";

export default {
  components: {
    GalleryController: () => import("~/components/GalleryController.vue"),
    HashController,
    Thumb,
  },
  data() {
    return {
      currentPhoto: null,
    };
  },
  methods: {
    // Update currentPhoto from the underlying gallery controller.
    updateCurrentPhoto: function (value) {
      this.currentPhoto = value;
    },
    // Brings up gallery displaying a specific photo.
    photoClicked: function (e) {
      this.updateCurrentPhoto(
        _.map(this.allPhotos, "href").indexOf(e.target.dataset.gcuPhoto)
      );
    },
    setCurrentPhoto: function (value) {},
    getGalleryIdx: function (filename) {
      return _.map(this.allPhotos, "href").indexOf(filename);
    },
    // // Handle url fragment.
    // handleHash: function () {
    //   const dateRe = /#\d\d\d\d-\d\d-\d\d/;
    //   const photoRe = /#photo\d+/;
    //   const fragment = location.hash;
    //   if (dateRe.test(fragment)) {
    //     console.log("it's a date!");
    //   } else if (photoRe.test(fragment)) {
    //     console.log("it's a photo number!");
    //     const n = Number(fragment.slice(6));
    //     if (n > 0 && n < this.allPhotos.length) {
    //       this.currentPhoto = n - 1;
    //     }
    //   } else {
    //     console.log("meh, weird fragment");
    //   }
    // },
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
  // watch: {
  //   $route(to, from) {
  //     this.handleHash();
  //   },
  // },
  // mounted() {
  //   this.handleHash();
  // },
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