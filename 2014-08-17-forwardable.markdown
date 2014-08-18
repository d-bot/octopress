---
layout: post
title: "Forwardable"
date: 2014-08-17 08:17:17 +0000
comments: true
categories: Forwardable
---

[참고](http://oneofthesedaysblog.com/ruby-day-4-forwardable)

Forwardable 은 기본적으로 다른 객체의 함수들을 wrapping 할때 사용되며, 함수의 추상화 레벨을 구현하게 해준다. (Forwardable is not a class. It's a module so you can extend or include it).


```ruby
class DBControl
	def newMySQL
	end

	def newPostgreSQL
	end

	def newSQLite3
	end
end

require 'forwardable'

class MyDatabase
  extend Forwardable

	def_delegators :@db, :newMySQL, :newPostgreSQL, :newSQLite3
  def_delegator :@db, :newMySQL, :create

  def initialize
    @db = DBControl.new
  end
end

db = MyDatabase.new
db.create			# Created new MySQL database


# 여기서 만약 Postgresql 의 newPostgreSQL 함수로 디비를 생성하기를 원한다면 아래와 같이 re-delegation
def_delegator :@db, :newPostgreSQL, :new

db = MyDatabase.new
db.create			# Created new PostgreSQL database

```
