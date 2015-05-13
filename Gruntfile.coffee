module.exports = (grunt) ->
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-react'
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
				files: ['src/public/coffee/*']
				tasks: ['coffee:public']

			coffeePrivate:
				files: 'src/private/**/*'
				tasks: ['coffee:private']

			stylus:
				files: 'src/public/stylus/*'
				tasks: ['stylus:compile']

			react:
				files: 'src/public/jsx/*'
				tasks: ['react:compile']

			livereload:
				options:
					livereload: true
				files: ['public/**/*', 'private/**/*', 'src/public/jade/**/*']

		coffee:
			public:
				expand: true
				flatten: true
				src: '<%= watch.coffeePublic.files %>.coffee'
				dest: 'public/js'
				ext: '.js'
			# try to reuse watch config files
			private:
				expand: true
				src: '**/*.coffee'
				dest: 'private'
				cwd: 'src/private'
				ext: '.js'

		stylus:
			compile:
				expand: true
				flatten: true
				src: '<%= watch.stylus.files %>.styl'
				dest: 'public/css'
				ext: '.css'

		react:
			compile:
				files: [
					expand: true
					flatten: true
					src: "<%= watch.react.files %>.jsx"
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
					{expand: true, flatten: true, src: 'src/assets/i/*', dest: 'public/i/'},
					{expand: true, flatten: true, src: 'src/assets/fonts/*', dest: 'public/fonts/'}
                    {expand: true, flatten: true, src: 'src/assets/models/*', dest: 'private/models/'}
				]

	grunt.registerTask('default', [
		'coffee:private',
		'coffee:public',
		'react:compile',
		'stylus:compile',
		'copy:src',
		'concurrent:dev'])

	grunt.registerTask('build', [
		'coffee:private',
		'coffee:public',
		'react:compile',
		'stylus:compile',
		'copy:src'])
