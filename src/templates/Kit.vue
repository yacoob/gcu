<template>
  <div>
    <i>{{ $page.kit.id }}</i>
    <br />
    <g-link :to="gradeLink">↖️ {{ $page.kit.grade.title }}</g-link>
    <br />
    <g-link v-if="$page.kit.prev" :to="$page.kit.prev.path">
      ⬅️ {{ $page.kit.prev.title }}
    </g-link>
    <br />
    <g-link v-if="$page.kit.next" :to="$page.kit.next.path">
      ➡️ {{ $page.kit.next.title }}
    </g-link>
    <Cover :width="200" :height="200" :photo-file="$page.kit.cover">
      {{ $page.kit.grade.title }}: {{ $page.kit.title }}
    </Cover>
    <hr />
    <HashController
      :current-photo="currentPhoto"
      :date-mapping="firstPhotoPerEntry"
      :photo-count="allPhotos.length"
      @gallery-moved-to="updateCurrentPhoto"
    />
    <ClientOnly>
      <GalleryController
        :images="allPhotos"
        :requested-photo="currentPhoto"
        @gallery-moved-to="updateCurrentPhoto"
      />
    </ClientOnly>
    <div v-for="entry in orderedEntries" :key="entry.date">
      <h2>{{ entry.date }}</h2>
      <Thumb
        v-for="photo in entry.photos"
        :id="'photo' + getGalleryIdx(photo.href)"
        :key="photo.href"
        :title="photo.title"
        :photo-file="photo.href"
        @click.native="photoClicked"
      />
    </div>
  </div>
</template>

<script>
import _ from 'lodash';
import Cover from '~/components/Cover.vue';
import Thumb from '~/components/Thumb.vue';
import HashController from '~/components/HashController.vue';

export default {
  components: {
    Cover,
    GalleryController: () => import('~/components/GalleryController.vue'),
    HashController,
    Thumb
  },
  data() {
    return {
      currentPhoto: null
    };
  },
  computed: {
    // All entry objects in chronological order.
    orderedEntries: function () {
      return _.orderBy(this.$page.kit.entries, 'date');
    },
    // All photo objects across all entries in chronological order.
    allPhotos: function () {
      return _.flatMap(this.orderedEntries, 'photos');
    },
    firstPhotoPerEntry: function () {
      return new Map(
        this.orderedEntries.map((entry) => [
          entry.date,
          this.allPhotos.indexOf(entry.photos[0])
        ])
      );
    },
    gradeLink: function () {
      return '/' + this.$page.kit.grade.title.toLowerCase();
    }
  },
  methods: {
    // Update currentPhoto from the underlying gallery controller.
    updateCurrentPhoto: function (value) {
      this.currentPhoto = value;
    },
    // Brings up gallery displaying a specific photo.
    photoClicked: function (e) {
      this.updateCurrentPhoto(
        _.map(this.allPhotos, 'href').indexOf(e.target.dataset.gcuPhoto)
      );
    },
    getGalleryIdx: function (filename) {
      return _.map(this.allPhotos, 'href').indexOf(filename);
    }
  }
};
</script>

<page-query>
query ($id: ID!) {
  kit(id: $id) {
    id
    title
    grade {
      title
    }
    prev: prevGradeKit {
      id
      title
      path
    }
    next: nextGradeKit {
      id
      title
      path
    }
    cover
    entries {
      date(format: "YYYY-MM-DD")
      photos {
        title
        href
      }
    }
  }
}
</page-query>