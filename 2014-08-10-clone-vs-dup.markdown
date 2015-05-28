---
layout: post
title: "clone vs dup"
date: 2014-08-10 23:20:38 +0000
comments: true
categories: Ruby
---

[참고](http://aaronlasseigne.com/2014/07/16/know-ruby-clone-and-dup/)

### dup 은 얕은 복사로 객체를 복사한다. 즉, 기존에 존재하는 값들은 모두 원본을 참조하며 새로 추가되는것은 원본에 영향을 미치지 않는다. (dup 을 clone 보다 더 자주 사용하는 이유). 그리고 dup 은 싱글턴 메서드들은 복사하지 못하지만 clone 은 싱글턴 메서드까지 복사가능

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

# 값을 아예 할당해 버리면 새로 할당된 값들은 원본을 참조하지 않음??

2.2.0p0 :001 > a = %w/ 1 2 3 4 5 /
 => ["1", "2", "3", "4", "5"]

2.2.0p0 :002 > b = a.dup
 => ["1", "2", "3", "4", "5"]

2.2.0p0 :007 > b[0] = "qwer"
 => "qwer"
2.2.0p0 :008 > b
 => ["qwer", "2", "3", "4", "5"]
2.2.0p0 :010 > a
 => ["1", "2", "3", "4", "5"]

2.2.0p0 :015 > b[2].sub!('3', '3333')
 => "3333"
2.2.0p0 :016 > b
 => ["qwer", "2", "3333", "4", "5"]
2.2.0p0 :017 > a
 => ["1", "2", "3333", "4", "5"]
```
