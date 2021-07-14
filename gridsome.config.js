// This is where project configuration and plugin options are located.
// Learn more: https://gridsome.org/docs/config

// Changes here require a server restart.
// To restart press CTRL + C in terminal and run `gridsome develop`

const _SITE_NAME = 'GCU Tactical Grace'
const _SITE_URL = 'https://gridsome--gcu.netlify.app'

module.exports = {
  siteName: _SITE_NAME,
  siteUrl: _SITE_URL,
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
      use: '@microflash/gridsome-plugin-feed',
      options: {
        contentTypes: ['EntriesCache'],
        maxItems: 15,
        rss: {
          enabled: true,
          output: '/rss.xml'
        },
        feedOptions: {
          description: `Newest kits from ${_SITE_NAME}`,
          generator: 'smol green Haro',
        },
        nodeToFeedItem: (node) => ({
          title: `${node.date.toISOString().slice(0, 10)}: ${node.title}`,
          date: node.date,
          link: `${_SITE_URL}${node.url}`,
          //FIXME: this needs to be better and handle youtube links; I can't Cover.vue tho :/
          content: node.photos.map(p => `<img src="${_SITE_URL}/photos/thumb/${p.href}" />`).join('\n'),
        })
      }
    }
  ],
  templates: {
    Kit: '/:fileInfo__directory/:fileInfo__name',
    Grade: '/:title',
  },
}
