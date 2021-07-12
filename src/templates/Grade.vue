<template>
  <div>
    <h1>{{ $page.grade.title }}</h1>
    <g-link to="/">↖️ main page</g-link>
    <hr />
    <g-link
      v-for="kit in $page.grade.belongsTo.edges"
      :key="kit.node.path"
      :to="kit.node.path"
    >
      <Cover :width="200" :height="200" :photo-file="kit.node.cover">
        {{ kit.node.title }}
      </Cover>
    </g-link>
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
query allHgKits($id: ID!) {
  grade(id: $id) {
    title
    belongsTo(sortBy: "title", order: ASC) {
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
</page-query>