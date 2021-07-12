<template>
  <h3>
    <Thumb :width="300" :height="300" :photo-file="photoFile" />
    <slot />
  </h3>
</template>

<script>
import Thumb from '~/components/Thumb';

export default {
  name: 'Cover',
  components: {
    Thumb
  },
  props: {
    width: {
      type: Number,
      default: 100
    },
    height: {
      type: Number,
      default: 100
    },
    photoFile: {
      type: String,
      required: true
    },
    title: {
      type: String,
      default: null
    }
  }
};
</script>