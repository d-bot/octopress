---
layout: post
title: "Custom iterators"
date: 2014-12-13 10:16:11 +0000
comments: true
categories: 
---

```ruby
# Custom Iterator
class Song
	include Enumerable

  def initialize(name)
    @name = name
    @songs = []
  end

  def add_song(song)
    @songs << song
  end

  def each
    @songs.each { |song| yield song }
  end

  def play_songs
    @songs.each { |song| puts "#{song.play}" }
  end

  def each_by_artist(artist)
    @songs.select { |song| song.artist == artist }.map { |song| yield song }
	end

  def my_reduce(sum)
    each do |value|
      yield(sum, value)
    end
  end

end

```

```ruby
# Map/Select methods

module MyEnumerable
  def my_map
    new_array = []
    each do |value|
      new_array << yield(value)
    end
    new_array
  end

  def my_select
    new_array = []
    each do |value|
      new_array << value if yield(value)
    end
    new_array
  end

	def my_detect
		each do |value|
			return value if yield(value)
		end
		nil
	end

	def my_any?
		each do |value|
			return true if yield(value)
		end
		false
	end
end
```

```ruby
#그냥 루프 탈출하는법 안까먹을려고 (return)
def my_any?
  each do |value|
    return true if yield(value)
  end
  false
end
```

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
