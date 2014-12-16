---
layout: post
title: "Initialize with a block"
date: 2014-12-16 15:48:49 +0000
comments: true
categories: 
---

블락을 받아서 해당 값으로 객체를 초기화함. 생각보다 쓸데가 많음.


```ruby
class Canvas
  attr_accessor :width, :height, :color

  def initialize
    @width = 100
    @height = 100
    @color = :black
    yield(self) if block_given?		# 블락을 받기 위해 initialize method 에서 정의해야할 부분
  end

  def drawRect(x, y, width, height)
    # draws a rectangle
  end

  def to_s
    "#{@width}x#{@height} #{@color} canvas"
  end
end

canvas = Canvas.new do |c|
 c.width = 800
 c.height = 600
 c.color = :green
end

puts canvas
```

OptParser

```ruby
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"
  opts.separator ""

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end
```

Faraday
```ruby
conn = Faraday.new("https://twitter.com/search") do |faraday|
	faraday.params["q"] = "ruby"
	faraday.params["src"] = "typd"
	faraday.response			:logger
	faraday.adapter				Faraday.default_adapter
end
```

