<template>
  <div>
    <h1>All kits made by GCU.</h1>
    <ul>
      <li v-for="edge in $page.kits.edges" :key="edge.node.id">
        <g-link :to="edge.node.path">
          {{ edge.node.grade.title }}: {{ edge.node.title }}
        </g-link>
      </li>
    </ul>
  </div>
</template>

<page-query>
query allAvailableKits {
  kits: allKit(
    sort: [{ by: "grade", order: ASC }, { by: "title", order: ASC }]
  ) {
    edges {
      node {
        id
        path
        title
        grade {
          title
        }
      }
    }
  }
}
</page-query>