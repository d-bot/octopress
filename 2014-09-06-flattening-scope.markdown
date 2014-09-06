---
layout: post
title: "Flattening Scope"
date: 2014-09-06 18:29:39 +0000
comments: true
categories: 
---

Good to know.

```ruby
my_var = "Success"

MyClass = Class.new do
	"#{my_var} in the class definition"

	define_method :my_method do
		"#{my_var} in the method"
	end
end


```
