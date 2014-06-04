
# Inspired by node-metainspector, rewritten for kicks

request = require 'request'
cheerio = require 'cheerio'
{EventEmitter} = require 'events'
URL = require 'url'

class Squeegee extends EventEmitter

	constructor: (@url) ->
		# @url = URI.normalize @withDefaultScheme(url)
		# @parsedUrl = URI.parse @url
		# @rootUrl = "#{@parsedUrl.scheme}://#{@parsedUrl.host}"
		# console.log url
		# console.log @url
		# console.log @parsedUrl
		# console.log @rootUrl

	# withDefaultScheme: (url) ->
	# 	a = URI.parse(url).scheme ? url : "http://" + url
	# 	console.log a
	# 	return a

	fetch: ->
		console.log "Making request to #{@url}"
		request
			uri: @url
		, (err, res, body) =>
			unless err
				if res.statusCode is 200
					console.log "got data from #{@url}"
					@document = body
					@parsedDocument = cheerio.load body
					# @res = res
					# @emit 'fetch'
					# Parse out some stuff
					@parse()
				else
					@emit 'error', "Got non-200 status code: #{res.statusCode}"
			else
				@emit 'error', err

	parse: ->

		console.log "parsing..."

		# Titles
		@title = @parsedDocument('title').text()
		@ogTitle = @parsedDocument("meta[property='og:title']").attr("content")

		# Links
		@links = @parsedDocument('a').map (i, elem) =>
			@parsedDocument(elem).attr('href')

		# Descriptions
		@metaDescription = @parsedDocument("meta[name='description']").attr("content")
		@parsedDocument('p').each (i, elem) =>
			text = @parsedDocument(elem).text()
			# Look for at least 140 characters. Or, "long-form"
			if text.length > 140
				@firstParagraph = text

		@description = if @metaDescription then @metaDescription else @firstParagraph

		# Image
		@image = @parsedDocument("meta[property='og:image']").attr("content")

		# Icon
		# Try apple-touch, then .ico
		# appleIcon = URL.resolve @url, @parsedDocument("link[rel=apple-touch-icon-precomposed]").attr("href")
		@icon = URL.resolve @url, '/favicon.ico'


		# Stuff has been parsed
		@emit 'parse'

module.exports = Squeegee
