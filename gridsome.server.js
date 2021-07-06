// Server API makes it possible to hook into various parts of Gridsome
// on server-side and add custom data to the GraphQL data layer.
// Learn more: https://gridsome.org/docs/server-api/

// Changes here require a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`


module.exports = function (api) {
  api.onCreateNode(options => {
    // For kit files, set the grade equal to the name of the directory the file
    // resides in.
    if (options.internal.typeName === "Kit") {
      const dirName = options.fileInfo.directory
      if (dirName.length > 2) {
        options.grade = dirName.charAt(0).toUpperCase() + dirName.slice(1)
      } else {
        options.grade = dirName.toUpperCase()
      }
    }
  })
  api.loadSource(({ addCollection }) => {
    // Use the Data Store API here: https://gridsome.org/docs/data-store-api/
  })

  api.createPages(({ createPage }) => {
    // Use the Pages API here: https://gridsome.org/docs/pages-api/
  })
}
