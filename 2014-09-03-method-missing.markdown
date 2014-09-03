---
layout: post
title: "Method_Missing"
date: 2014-09-03 06:48:49 +0000
comments: true
categories: 
---

method_missing 은 일종의 Dynamic Proxy 처럼 동작하여 없는 method 들이 호출되었을때 해당 method 를 갖고 있는 다른 객체로 받은 메세지(method)를 forwarding 해주는 기능을 하게 된다. (일종의 abstraction 을 가능하게 해줌)

```ruby

class Computer
	def initialize(computer_id, data_source)
		@id = computer_id
		@data_source = data_source
	end

	def method_missing(name)
		super if !@data_source.respond_to?("get_#{name}_info")
		info = @data_source.send("get_#{name}_info", @id)
		price = @data_source.send("get_#{name}_price", @id)

		result = "#{name.capitalize}: #{info} ($#{price})"
		return "* #{result}" if price >= 100
		result
	end
end

```
