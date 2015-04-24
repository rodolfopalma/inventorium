module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-react'
	grunt.loadNpmTasks 'grunt-contrib-jade'
	grunt.loadNpmTasks 'grunt-contrib-stylus'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-concurrent'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-nodemon'

	grunt.initConfig

		concurrent:
			dev: ['watch', 'nodemon:dev'],
			options: {
				logConcurrentOutput: true
			}

		watch:
			coffeePublic:
				files: ['src/public/coffee/*.coffee']
				tasks: ['coffee:public']

			coffeePrivate:
				files: 'src/private/*.coffee'
				tasks: ['coffee:private']

			jade:
				files: 'src/public/jade/*.jade'
				tasks: ['jade:compile']

			stylus:
				files: 'src/public/stylus/*.styl'
				tasks: ['stylus:compile']

			react:
				files: 'src/public/jsx/*.jsx'
				tasks: ['react:compile']

			livereload:
				options:
					livereload: true
				files: ['public/**/*', 'private/**/*']

		coffee:
			public:
				expand: true
				flatten: true
				src: '<%= watch.coffeePublic.files %>'
				dest: 'public/js'
				ext: '.js'					
			private:
				expand: true
				flatten: true
				src: '<%= watch.coffeePrivate.files %>'
				dest: 'private'
				ext: '.js'

		jade:
			compile:
				expand: true
				flatten: true
				src: '<%= watch.jade.files %>'
				dest: 'public'
				ext: '.html'

		stylus:
			compile:
				expand: true
				flatten: true
				src: '<%= watch.stylus.files %>'
				dest: 'public/css'
				ext: '.css'

		react:
			compile: 
				files: [
					expand: true
					cwd: "src/public/jsx"
					src: "*.jsx"
					dest: "public/js"
					ext: ".js"
				]

		nodemon:
			dev:
				script: 'private/server.js'

		copy:
			src:
				files: [
					{expand: true, flatten: true, src: 'src/assets/css/*', dest: 'public/css/'},
					{expand: true, flatten: true, src: 'src/assets/js/*', dest: 'public/js/'},
					{expand: true, flatten: true, src: 'src/assets/i/*', dest: 'public/i/'}					
				]

	grunt.registerTask('default', [
		'coffee:private', 
		'coffee:public',
		'react:compile',
		'jade:compile', 
		'stylus:compile',
		'copy:src', 
		'concurrent:dev'])
