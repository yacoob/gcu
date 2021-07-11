<template>
  <Layout>
    <h1>🤖😺😺😺</h1>
    <ul>
      <li v-for="entry in $page.entries.edges" :key="entry.url">
        <g-link :to="entry.node.url">
          <Thumb :width="200" :height="200" :photoFile="entry.node.cover" />
          {{ entry.node.date }}: {{ entry.node.kit.title }}
        </g-link>
      </li>
    </ul>
    <hr />
    <small><g-link to="/everything/">...or just see EVERYTHING!</g-link></small>
  </Layout>
</template>

<script>
import Thumb from "~/components/Thumb.vue";

export default {
  components: {
    Thumb,
  },
  metaInfo: {
    title: "Welcome to GCU Tactical Grace!",
  },
};
</script>

<page-query>
query allEntries {
  entries: allEntriesCache(sortBy:"date", limit:3, skip: 5) {
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