<template>
  <img
    :width="width"
    :height="height"
    :src="href"
    :title="title"
    :data-gcu-photo="photoFile"
  />
</template>

<script>
export default {
  name: "Thumb",
  props: {
    width: {
      type: Number,
      default: 100,
    },
    height: {
      type: Number,
      default: 100,
    },
    photoFile: {
      type: String,
      required: true,
    },
    title: String,
  },
  computed: {
    href: function () {
      if (this.photoFile.includes("youtu.be/")) {
        const vId = this.photoFile.split("/").pop();
        return "https://img.youtube.com/vi/" + vId + "/0.jpg";
      } else {
        return "/photos/thumb/" + this.photoFile;
      }
    },
  },
};
</script>