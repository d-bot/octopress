---
layout: post
title: "Simple Logging Module"
date: 2014-08-07 09:07:44 +0000
comments: true
categories: Ruby
---

간단한 로깅 모듈. 특별한것은 없고 Singleton 클래스를 이용해서 글로벌한 하나의 객체를 이용하여 어디서든 해당 모듈을 include 하여 사용 가능하도록 구현.

```ruby
require 'singleton'
module Logging

	def info(msg)
		return Logger.instance.out(msg, "INFO")
	end
	def warn(msg)
		return Logger.instance.out(msg, "WARN")
	end
	def error(msg)
		return Logger.instance.out(msg, "ERROR")
	end

	class Logger
		include Singleton

		def initialize
			@log = File.open("LOG_PATH", "a")
		end

		def out(msg, level)
			@log.puts("#{level[0]}, [#{Time.now}]  #{level} -- : #{msg}")
			@log.flush
		end

	end
end
```

