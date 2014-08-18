---
layout: post
title: "ruby shorthand forms"
date: 2014-08-10 09:44:10 +0000
comments: true
categories: shorthand
---
From http://www.toptal.com/ruby/interview-questions

```ruby
list = ["ship", "airplane", "bus"]

list.map(&:reverse)  # same as list.map { |n| n.reverse }

# ["pihs", "enalpria", "sub"]

```
& 는 주로 one-line iteration 에서 종종 등장하는 shorthand. 즉, 파라미터를 넘길때 & 를 붙여서 넘기면 루비는 to_proc 를 호출하는 기능을 이용한 숏컷임.

```ruby
fuction = Proc.new |n| { n.reverse }
%w/ ship airplane bus /.map(&fuction)

# ["pihs", "enalpria", "sub"]
```

Lambda syntax sugar
```ruby
%w/ ship airplane bus /.map &(->(n) { n.reverse })
=> ["pihs", "enalpria", "sub"]
```
