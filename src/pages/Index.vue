<template>
  <Layout>
    <h1>🤖😺😺😺</h1>
    <span v-for="grade in $page.grades.edges" :key="grade.node.id">
      ▶️
      <g-link :to="grade.node.path">
        {{ grade.node.id }}
      </g-link>
    </span>
    🔀
    <g-link to="/everything/">EVERYTHING!</g-link>
    <hr />
    <g-link
      v-for="entry in $page.entries.edges"
      :key="entry.url"
      :to="entry.node.url"
    >
      <Cover :width="200" :height="200" :photo-file="entry.node.cover">
        {{ entry.node.date }}: {{ entry.node.kit.title }}
      </Cover>
    </g-link>
  </Layout>
</template>

<script>
import Cover from '~/components/Cover.vue';

export default {
  components: {
    Cover
  },
  metaInfo: {
    title: 'Welcome to GCU Tactical Grace!'
  }
};
</script>

<page-query>
query allEntries {
  entries: allEntriesCache(sortBy: "date", limit: 3, skip: 5) {
    edges {
      node {
        id
        date
        url
        cover
        kit {
          title
        }
      }
    }
  }
  grades: allGrade(sortBy: "id", order: ASC) {
    edges {
      node {
        id
        path
      }
    }
  }
}
</page-query>