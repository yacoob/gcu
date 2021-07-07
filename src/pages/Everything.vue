<template>
  <div>
    <h1>All kits made by GCU.</h1>
    <ul>
      <li v-for="edge in $page.allKit.edges" :key="edge.node">
        <g-link :to="edge.node.path"
          >{{ edge.node.grade }}: {{ edge.node.title }}</g-link
        >
      </li>
    </ul>
  </div>
</template>

<page-query>
query allAvailableKits {
  allKit(sort: [{by: "grade", order: ASC}, {by: "title", order: ASC}]) {
    edges {
      node {
        path
        title
        grade
      }
    }
  }
}

</page-query>