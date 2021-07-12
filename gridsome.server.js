// Server API makes it possible to hook into various parts of Gridsome
// on server-side and add custom data to the GraphQL data layer.
// Learn more: https://gridsome.org/docs/server-api/

// Changes here require a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`
const crypto = require('crypto')
const { merge } = require('lodash')

module.exports = function (api) {
  // Enable source-maps for local development.
  if (process.env.GRIDSOME_NODE_ENV === 'development') {
    api.configureWebpack(config => {
      return merge({
        devtool: 'source-map',
      }, config)
    })
  }

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

  api.loadSource(async actions => {
    // Go through kits, add prev/next fields within a grade.
    const kits = actions.getCollection('Kit')
    kits.addReference('prevGradeKit', 'Kit')
    kits.addReference('nextGradeKit', 'Kit')
    // Enumerate grades.
    const grades = actions.getCollection('Grade')
    for (const grade of grades.data()) {
      // Enumerate kits of single grade and sort them by kit title.
      const gradeKits = kits.findNodes({ 'grade': grade.id })
      gradeKits.sort((a, b) => {
        if (a.title == b.title) {
          return 0
        } else {
          return a.title > b.title ? 1 : -1
        }
      })
      var prev = null
      // Go through kits of a single grade, populate prev/next fields.
      for (const kit of gradeKits) {
        if (prev) {
          kit.prevGradeKit = actions.createReference(prev)
          prev.nextGradeKit = actions.createReference(kit)
        }
        prev = kit
      }
    }

    // Go through kits, add separate nodes for Entries. They're needed for RSS
    // and main page, url is sufficient.
    const entries = actions.addCollection('EntriesCache')
    entries.addReference('kit', 'Kit')
    kits.data().forEach((kit) => {
      kit.entries.forEach((entry) => {
        const date = entry.date.toISOString().slice(0, 10)
        const id = crypto.createHash('md5').update(date).update(kit.path).digest('hex')
        entries.addNode({
          id,
          date,
          url: [kit.path, '#', date].join(''),
          cover: entry.cover,
          kit: actions.createReference(kit)
        })
      })
    })
  })
}
