---
layout: post
title: "Define times and each"
date: 2014-12-13 10:16:11 +0000
comments: true
categories: 
---

Define times method

```ruby
#!/usr/bin/env ruby

class Integer
	def n_times
		i = 0
		while i < self
			yield i
			i += 1
		end
	end
end

5.n_times { |n| puts n }

```

Define each method

```ruby
#!/usr/bin/env ruby

class Array
	def my_each
		i = 0
		while i < self.size
			yield self[i]
			i += 1
		end
		self
	end
end

[1,2,3,4].my_each { |x| puts x }
```
