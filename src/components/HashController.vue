<template>
  <div id="hash-controller" />
</template>

<script>
export default {
  name: "HashController",
  data() {
    return {
      numberInHash: null,
    };
  },
  props: {
    currentPhoto: {
      type: Number,
      default: null,
    },
  },
  computed: {
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
      if (newValue !== null) {
        this.numberInHash = newValue + 1;
      } else {
        this.numberInHash = null;
      }
      history.replaceState(null, null, this.$route.path + this.expectedHash);
    },
  },
};
</script>

<page-query>
</page-query>