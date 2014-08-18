---
layout: post
title: "New Rack App"
date: 2014-08-13 07:46:33 +0000
comments: true
categories: Rack
---

Busan Framework
```ruby
# https://www.youtube.com/watch?v=iJ-ZsWtHTIg
class Busan
	def initialize(template)
		@response = []
		@template = template
	end

	def erb
		@response << File.open(@template).read
	end

	def call(env)
		["200", {"Content-Type" => "text/html"}, @response]

	end
end

#typical rack middleware setup

class PrintHeaders
	def initialize(app = nil)
		@app = app
	end

	def call(env)

		response = []

		if(@app)
			@app.call(env)[2].each { |body| response << body }
		end

		env.keys.each { |key| response << "<li>#{key} = #{env[key]}</li>" }

		["200", {"Content-Type" => "text/html"}, response]

	end
end

class Inject
	def initialize(app = nil)
		@app = app
	end

	def call(env)

		response = []

		env[:test] = "SysOps"

		if(@app)
			@app.call(env)[2].each { |body| response << body }
		end

		env.keys.each { |key| response << "<li>#{key} = #{env[key]}</li>" }

		["200", {"Content-Type" => "text/html", "Test" => "SysOps"}, response]

	end
end


class Filter
	def initialize(app = nil)
		@app = app
	end

	def call(env)

		response = []

		if(@app)
			i = 0
			@app.call(env)[2].each do |body|
				body.gsub!(/Rack/i, '')
			 	response << body
			end
		end

		#env.keys.each { |key| response << "<li>#{key} = #{env[key]}</li>" }

		["200", {"Content-Type" => "text/html"}, response]

	end
end

class MyApp < Busan
  def initialize(template)
		super
		erb
  end
end

class Header < PrintHeaders
end

#use Massive
#use PrintHeaders
#run MyApp.new
```

rackup app.ru

```ruby
require './busan'

map '/' do
	run MyApp.new("views/layout.erb")
end

map '/header' do
	#run PrintHeaders.new
	use PrintHeaders
	run MyApp.new("views/header.erb")
end

map '/filter' do
	#run PrintHeaders.new
	use Filter
	use PrintHeaders
	run MyApp.new("views/header.erb")
end

map '/inject' do
	#run PrintHeaders.new
	use Inject
	run MyApp.new("views/header.erb")
end
```


