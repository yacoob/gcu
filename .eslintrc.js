module.exports = {
  env: {
    node: true,
    es6: true
  },
  plugins: ['gridsome'],
  'extends': [
    'eslint:recommended',
    'plugin:vue/recommended',
    'prettier'
  ],
  rules: {
    'gridsome/format-query-block': 'error',
  },
  parser: 'vue-eslint-parser'
}