---
layout: post
title: "Exception"
date: 2015-05-15 07:13:49 +0000
comments: true
categories: 
---

#### Exception 을 잡을때 순서대로 rescue 되니까 잡고 싶은것 부터 먼저 rescue 로 잡고 나머지 broad 한 예외들을 마지막 resuce 절에 넣는다.

```ruby
begin
  task.perform
rescue ArgumentError, LocalJumpError,
      NoMethodError, ZeroDivisionError
      raise
rescue => e
  logger.error("task failed: #{e}")
end

```

```ruby
begin
  task.perform
rescue NetworkConnectionError => e
  #Retry logic...
rescue InvalidRecordError => e
  # Send record to support staff...
end
```
