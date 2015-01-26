module.exports = function(grunt) {
    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),

        copy: {
          main: {
            files: [
              {expand: true, cwd: 'lib/env/public/', src: ['**'], dest: 'public/env'}
            ]
          }
        },

        bower: {
          install: {
            options: {
              targetDir: './public/js/libs'
            }
          }
        },

        requirejs: {
            desktopJS: {
                options: {
                    baseUrl: "public/js/app",
                    banner: "CID-Web",
                    wrap: true,
                    wrapShim: true,
                    findNestedDependencies: true,
                    // Cannot use almond since it does not currently appear to support requireJS's config-map
                    name: "../libs/almond/almond",
                    preserveLicenseComments: false,
                    optimize: "uglify",
                    mainConfigFile: "public/js/app/config/config.js",
                    include: ["init/DesktopInit"],
                    out: "public/js/app/init/DesktopInit-<%= pkg.version %>.min.js"
                }
            },
            desktopCSS: {
                options: {
                    optimizeCss: "standard",
                    cssIn: "./public/css/desktop.css",
                    out: "./public/css/desktop.min.css"
                }
            }
        },
        jshint: {
            files: ['Gruntfile.js', 'public/js/app/**/*.js', '!public/js/app/**/*min.js'],
            options: {
                globals: {
                    jQuery: true,
                    console: false,
                    module: true,
                    document: true
                }
            }
        },

        watch: {
          another: {
            files: [ 'public/**/*.*' ],
            options: {
              livereload: true
            },
          }
        }
    });

    grunt.registerTask('makeEnvDir', 'Make dir for env modules', function(opts) {
      grunt.file.mkdir('public/env'); 
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-requirejs');
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-copy');
    grunt.loadNpmTasks('grunt-bower-task');

    grunt.registerTask('test', ['jshint']);
    grunt.registerTask('prepareBuild', ['makeEnvDir', 'copy:main']);
    grunt.registerTask('build', ['bower', 'prepareBuild', 'requirejs:desktopJS', 'requirejs:desktopCSS']);
    grunt.registerTask('default', ['test', 'build']);
};
