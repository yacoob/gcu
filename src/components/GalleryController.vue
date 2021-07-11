<!-- This component wraps lightGallery https://www.lightgalleryjs.com/ for GCU.

lightGallery (LG) has an official vue wrapper but it only works with v3 of vue.
This wrapper is rather crude and most likely doesn't handle all use cases well -
but it does work for my purposes. --->
<template>
  <div :id="id" />
</template>

<script>
import lightGallery from "lightgallery";
import lgThumbnail from "lightgallery/plugins/thumbnail";
import lgZoom from "lightgallery/plugins/zoom";
import lgVideo from "lightgallery/plugins/video";
import lgFullscreen from "lightgallery/plugins/fullscreen";
import lgAutoplay from "lightgallery/plugins/autoplay";
import "lightgallery/css/lightgallery-bundle.css";

export default {
  name: "GalleryController",
  props: {
    // images to be managed by LG
    images: {
      type: Array,
      required: true,
      // TODO: add a validator
    },
    // id of the node hosting the controller
    id: {
      type: String,
      default: "gallery-controller",
    },
    // photo requested by parent component to be displayed; it is kept in sync with currentPhoto
    requestedPhoto: {
      type: Number,
      default: null,
    },
  },
  data() {
    return {
      // LG plugin instance, once initialised
      lg: null,
      // LG's idea of which photo is being currently displayed, null if gallery is hidden
      // LG has lg.index property, but it retains old value after closing the gallery, so it can't be used as a reliable information.
      currentPhoto: null,
    };
  },
  watch: {
    // Handle new values of requestedPhoto, most likely assigned by the parent component.
    requestedPhoto(newValue, oldValue) {
      console.log(
        `GalleryController.vue: requestedPhoto watcher: changing ${oldValue} => ${newValue}`
      );
      // Is the requested photo different form the current one?
      if (this.currentPhoto == newValue) {
        return;
      }
      // Was I asked to close the gallery?
      if (newValue === null) {
        if (this.lg.lgOpened) {
          this.lg.closeGallery();
        }
      } else {
        // Is LG actually active right now?
        if (this.lg.lgOpened) {
          this.lg.slide(newValue);
        } else {
          this.lg.openGallery(newValue);
        }
      }
      // Sync our idea of current photo to the requested one.
      this.currentPhoto = newValue;
    },
  },
  mounted() {
    const lg_element = document.getElementById(this.id);
    // Close LG -> update currentPhoto, tell parent about this.
    lg_element.addEventListener("lgAfterClose", () => {
      this.currentPhoto = null;
      this.$emit("gallery-moved-to", null);
    });
    // LG moved to another slide -> update currentPhoto, tell parent about this.
    lg_element.addEventListener("lgAfterSlide", () => {
      this.currentPhoto = this.lg.index;
      this.$emit("gallery-moved-to", this.currentPhoto);
    });
    // Transform photo objects into objects that LG expects.
    const lgImages = this.images.map((p) => ({
      src: p.href.startsWith("https") ? p.href : "/photos/full/" + p.href,
      thumb: "/photos/thumb/" + p.href,
      subHtml: p.title,
    }));
    this.lg = lightGallery(lg_element, {
      plugins: [lgZoom, lgThumbnail, lgVideo, lgFullscreen, lgAutoplay],
      dynamic: true,
      dynamicEl: lgImages,
      hideBarsDelay: 2000,
      speed: 200,
      preload: 2,
      youtubePlayerParams: {
        autoplay: 0,
        controls: 0,
        modestbranding: 1,
        rel: 0,
        showinfo: 0,
      },
    });
    // Open after component creation if it has been requested.
    if (this.requestedPhoto !== null) {
      this.currentPhoto = this.requestedPhoto;
      this.lg.openGallery(this.requestedPhoto);
    }
  },
};
</script>
