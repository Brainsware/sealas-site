module.exports = function (grunt) {

  require('load-grunt-tasks')(grunt);

  grunt.initConfig ({
    pkg : grunt.file.readJSON('package.json'),

    clean: {
      css: ['css']
    },

    less:{
      app:{
        options: {
          paths: ['less']
        },
        files : {
          'css/raleway.css': 'less/raleway.less'
        }
      }
    },

    sass: {
      dist: {
        files: {
          'css/raleway.css': 'scss/raleway.scss'
        }
      }
    },

    cssmin :{
      app : {
        files : {
          'css/raleway.min.css': 'css/raleway.css'
        }
      }
    },

    // List available Grunt tasks & targets.
  availabletasks: {
    tasks: {
         options: {
            filter: 'exclude',
            tasks: ['availabletasks', 'default'],
            descriptions: {
               'build-less': 'Compile with the preprocessed LESS.',
               'build-sass': 'Compile with the preprocessed SASS.'
            },
             showTasks: ['user']
        }
    }
  }


  });


// -------------------------------------------------------------------------------------

  // Load available-tasks
 grunt.loadNpmTasks('grunt-available-tasks');
  // Default task
 grunt.registerTask('default', [ 'availabletasks']);

 grunt.registerTask('build-less', 'Starts build with LESS', function (target) {
    var tasks = {
      prep_build: [
        'clean'
      ],
      post_build:[
        'cssmin'
      ],
       default: [
        'build-less:prep_build'
        ,'less'
        ,'build-less:post_build'
      ]
    };

    grunt.task.run(tasks[target] || tasks['default']);
 });

 grunt.registerTask('build-sass', 'Starts build with SASS', function (target) {
    var tasks = {
      prep_build: [
        'clean'
      ],
      post_build:[
        'cssmin'
      ],
       default: [
        'build-sass:prep_build'
        ,'sass'
        ,'build-sass:post_build'
      ]
    };

    grunt.task.run(tasks[target] || tasks['default']);
 });

};
