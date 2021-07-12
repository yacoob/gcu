<template>
  <div>
    <h1>Everything!</h1>
    <g-link to="/">↖️ main page</g-link>
    <hr />
    <div v-for="grade in $page.everything.edges" :key="grade.node.id">
      <h2>{{ grade.node.title }}</h2>
      <g-link
        v-for="kit in grade.node.belongsTo.edges"
        :key="kit.node.path"
        :to="kit.node.path"
      >
        <Cover :width="200" :height="200" :photo-file="kit.node.cover">
          {{ kit.node.title }}
        </Cover>
      </g-link>
    </div>
  </div>
</template>

<script>
import Cover from '~/components/Cover.vue';

export default {
  components: {
    Cover
  }
};
</script>

<page-query>
query allAvailableKits {
  everything: allGrade(sortBy: "id", order: ASC) {
    edges {
      node {
        title
        id
        path
        belongsTo {
          edges {
            node {
              ... on Kit {
                title
                cover
                path
              }
            }
          }
        }
      }
    }
  }
}
</page-query>