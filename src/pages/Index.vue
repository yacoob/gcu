<template>
  <Layout>
    <h1>🤖😺😺😺</h1>
    <g-link
      v-for="entry in $page.entries.edges"
      :key="entry.url"
      :to="entry.node.url"
    >
      <Cover :width="200" :height="200" :photo-file="entry.node.cover">
        {{ entry.node.date }}: {{ entry.node.kit.title }}
      </Cover>
    </g-link>
    <hr />
    <small><g-link to="/everything/">...or just see EVERYTHING!</g-link></small>
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
}
</page-query>