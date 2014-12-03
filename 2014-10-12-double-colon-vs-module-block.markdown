---
layout: post
title: "Double colon vs module block"
date: 2014-10-12 20:10:39 +0000
comments: true
categories: 
---

간혹 소스코드를 보다 보면 클래스 선언시 class Library::Book 이렇게 선언하는데 이렇게 하기 위해서는 이미 Library 라는 모듈이 미리 선언되어 있어야함.

이렇게 사용하는 이유는 아마 class Library::Book 이렇게 선언하면 Library 모듈의 scope 를 오픈하지 않고 바로 Book 클래스의 scope 를 오픈하기 때문인걸로 추측

```ruby
module Library
  Test = "Library"
end

class Library::Book
  Test = "Book"
  #puts Library::Test
  #puts Test
end

puts Library::Book::Test
puts Library::Test
#Library::Book.new
```
