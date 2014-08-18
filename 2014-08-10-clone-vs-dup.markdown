---
layout: post
title: "clone vs dup"
date: 2014-08-10 23:20:38 +0000
comments: true
categories: 
---

From http://aaronlasseigne.com/2014/07/16/know-ruby-clone-and-dup/

기본적으로 거의 같으나 clone 이 dup 에 비해서 기능이 몇개 더 있음.

* clone
	* The frozen state of the object is also copied.
* dup
	* It'll alwyas be thawed
	* You'll lose singleton methods added to the original object
	* 복사할때 원본 객체가 가지고 있던 값은 공유된다. 즉 복사한 새로운 객체의 기존에 존재하는 값을 수정하면 원본도 수정이 된다.

```ruby
2.0.0p353 :001 > f = 'Frozen'.freeze
 => "Frozen"
2.0.0p353 :002 > f.frozen?
 => true
2.0.0p353 :003 > f.clone.frozen?
 => true
2.0.0p353 :004 > f.dup.frozen?
 => false
2.0.0p353 :005 >
2.0.0p353 :006 > a = ["qwer", "asdf", "zxcv"]
 => ["qwer", "asdf", "zxcv"]
2.0.0p353 :007 > b = a.dup
 => ["qwer", "asdf", "zxcv"]
2.0.0p353 :008 > b[1].sub!('asdf', 'new-asdf')
 => "new-asdf"
2.0.0p353 :009 > p b
["qwer", "new-asdf", "zxcv"]
 => ["qwer", "new-asdf", "zxcv"]
2.0.0p353 :010 > p a
["qwer", "new-asdf", "zxcv"]
 => ["qwer", "new-asdf", "zxcv"]
2.0.0p353 :011 > b << "asdf"
 => ["qwer", "new-asdf", "zxcv", "asdf"]
2.0.0p353 :012 > p a
["qwer", "new-asdf", "zxcv"]
 => ["qwer", "new-asdf", "zxcv"]
2.0.0p353 :013 > p b
["qwer", "new-asdf", "zxcv", "asdf"]
 => ["qwer", "new-asdf", "zxcv", "asdf"]
```
