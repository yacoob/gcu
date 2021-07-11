<template>
  <div>
    <i>{{ $page.kit.id }} </i>
    <h1>
      <Thumb :width="200" :height="200" :photoFile="$page.kit.cover" />
      {{ $page.kit.grade }}:
      {{ $page.kit.title }}
    </h1>
    <HashController
      @gallery-moved-to="updateCurrentPhoto"
      :currentPhoto="currentPhoto"
      :photoCount="allPhotos.length"
    />
    <ClientOnly>
      <GalleryController
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
    firstPhotoPerEntry: function () {
      return new Map(
        this.orderedEntries.map((entry) => [
          entry.date,
          this.allPhotos.indexOf(entry.photos[0]),
        ])
      );
    },
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