// This is where project configuration and plugin options are located.
// Learn more: https://gridsome.org/docs/config

// Changes here require a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`

module.exports = {
  siteName: 'GCU Tactical Grace',
  plugins: [
    {
      use: '@gridsome/source-filesystem',
      options: {
        typeName: 'Kit',
        path: '*/*.yaml',
        baseDir: './kits',
      }
    }
  ],
  templates: {
    Kit: '/:fileInfo__directory/:fileInfo__name'
  },
}
