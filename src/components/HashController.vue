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
    // Update URL hash if current photo has changed.
    currentPhoto(newValue, oldValue) {
      console.log(`HashController watcher: ${oldValue} --> ${newValue}`);
      history.replaceState(null, null, this.$route.path + this.expectedHash);
    },
  },
};
</script>

<page-query>
</page-query>