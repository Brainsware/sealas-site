module.exports = (grunt) ->
  grunt.initConfig
    concat:
      styles:
        src: [
          "node_modules/bootstrap/dist/css/bootstrap.min.css",
          "htdocs/styles/site/dark.css",
          "htdocs/styles/site/style.css",
          "htdocs/styles/site/responsive.css",
        ]
        dest: 'htdocs/styles/front.css'
    browserify:
      client:
        options:
          browserifyOptions:
            extensions: [ '.coffee' ]
            debug: false
          transform: [ 'coffeeify' ]
        src: [ 'src/coffee/site.coffee' ]
        dest: 'htdocs/site.js'
    sass:
      files:
        expand: true
        cwd: 'src/css'
        src: ['*.sass']
        dest: 'htdocs/styles'
        ext: '.css'

  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-browserify'

  grunt.registerTask 'default', ['browserify', 'concat']
