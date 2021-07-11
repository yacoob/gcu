<!-- "He who controls the hash controls the gallery.
                          -- Princess Irulan,
                             (or sth idk, never read Dune 8) -->
<template>
  <div id="hash-controller" />
</template>

<script>
export default {
  name: "HashController",
  props: {
    currentPhoto: {
      type: Number,
      default: null,
    },
    photoCount: {
      type: Number,
      required: true,
    },
    dateMapping: {
      type: Map,
      required: true,
    },
  },
  computed: {
    numberInHash: function () {
      if (this.currentPhoto !== null) {
        return this.currentPhoto + 1;
      } else {
        return null;
      }
    },
    expectedHash: function () {
      if (this.numberInHash !== null) {
        return "#photo" + this.numberInHash;
      } else {
        return "";
      }
    },
  },
  watch: {
    $route(to, from) {
      if (to.path === from.path && to.hash !== from.hash) {
        this.parseUrlAndUpdateHash();
      }
    },
    // Update URL hash if current photo has changed.
    currentPhoto(newValue, oldValue) {
      console.log(`HashController watcher: ${oldValue} --> ${newValue}`);
      this.setUrlsHashToExpectations();
    },
  },
  mounted() {
    console.log(
      `HashController: I think there are ${this.photoCount} photos here.`
    );
    console.log(
      `HashController: my current idea about what is the number in hash: ${this.numberInHash}`
    );
    this.parseUrlAndUpdateHash();
  },
  methods: {
    setUrlsHashToExpectations: function () {
      history.replaceState(null, null, this.$route.path + this.expectedHash);
    },
    // Handle url hash.
    parseUrlAndUpdateHash: function () {
      const dateRe = /#(\d\d\d\d-\d\d-\d\d)/;
      const photoRe = /#photo(\d+)/;
      const hash = location.hash;
      if (hash) {
        // If I determine a photo number from the hash, we will emit a signal
        // that page should move.
        let targetPhoto = this.currentPhoto;
        if (dateRe.test(hash)) {
          // There's an YYYY-MM-DD date in the hash.
          console.log("it's a date!");
          const n = Number(this.dateMapping.get(hash.match(dateRe)[1]));
          targetPhoto = n >= 0 ? n : null;
        } else if (photoRe.test(hash)) {
          // There's a photo indicator in the hash.
          console.log("it's a photo number!");
          const n = Number(hash.match(photoRe)[1]);
          // Check whether requested photo is within expected range.
          if (n >= 1 && n <= this.photoCount) {
            targetPhoto = n - 1;
          } else {
            targetPhoto = null;
          }
        } else {
          // There was a hash, but I couldn't parse it.
          targetPhoto = null;
        }
        // Inform parent about new photo number that I've worked out from the hash.
        this.$emit("gallery-moved-to", targetPhoto);
        // Special case:
        // - there was a hash
        // - and parsing of it suggests it doesn't point at any sensible photo
        // - and gallery is closed.
        // This might happen during initial page load, and because
        // targetPhoto==currentPhoto==null already, the above $emit doesn't
        // clear the hash in url.
        if (targetPhoto == null && this.currentPhoto == null) {
          this.setUrlsHashToExpectations();
        }
      }
    },
  },
};
</script>