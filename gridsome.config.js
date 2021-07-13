// This is where project configuration and plugin options are located.
// Learn more: https://gridsome.org/docs/config

// Changes here require a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`

module.exports = {
  siteName: 'GCU Tactical Grace',
  siteUrl: 'https://gridsome--gcu.netlify.app/',
  plugins: [
    {
      use: '@gridsome/source-filesystem',
      options: {
        typeName: 'Kit',
        path: '*/*.yaml',
        baseDir: './kits',
        refs: {
          // This field is not present in the file; I set it in
          // gridsome.server.js via onCreateNode.
          grade: {
            typeName: 'Grade',
            create: true
          }
        }
      }
    },
    {
      use: '@gridsome/plugin-sitemap',
    }
  ],
  templates: {
    Kit: '/:fileInfo__directory/:fileInfo__name',
    Grade: '/:title',
  },
}
