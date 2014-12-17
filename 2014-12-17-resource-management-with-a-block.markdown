---
layout: post
title: "Resource management with a block"
date: 2014-12-17 02:13:40 +0000
comments: true
categories: 
---

블락을 이용하여 객체 생성 및 제거등의 리소스 관리를 편리하게 하는 기법. 주로 메모리 소모가 많거나 한정된 자원을 다룰때 자주 사용됨.

```ruby
class DatabaseDriver
  def initialize(database, user, password)
    @database = database
    @user = user
    @password = password
    @connected = false
  end

  def connect
    # connects to database
    @connected = true
    puts "Connected to #{@database} as #{@user}."
  end

  def disconnect
    # disconnects from database
    puts "Disconnected."
  end

  def execute(sql)
    raise "Not connected!" unless @connected
    puts "Executing #{sql}..."
    # executes SQL
  end

  def self.open(database, user, password)
    driver = self.new(database, user, password)
    driver.connect
    return driver unless block_given?
    begin
      yield(driver)
    ensure				# rescue 를 정의하지 않았으므로 yield 에서 리턴된 예외는 최상위 에러로 올라가서 유저에게 보여진다.
      driver.disconnect
    end
  end
end

driver = DatabaseDriver.open("my_database", "admin", "secret")
driver.execute("SELECT * FROM ORDERS")
driver.execute("SELECT * FROM USERS")
driver.disconnect

DatabaseDriver.open("my_database", "admin", "secret") do |driver|
  driver.execute("SELECT * FROM ORDERS")
  raise "Boom!"
  driver.execute("SELECT * FROM USER")
end
```

Ruby/DBI
```ruby
def connect(db_args, user, auth, params)
  dbh = DatabaseHandle.new(...)
  if block_given?
    begin
      yield dbh
    ensure
      dbh.disconnect if dbh.connected?
    end
  else
    dbh
  end
end
```

File Class
```ruby
class File
  def self.open(filename, mode)
    file = self.new(filename, mode)
    return file unless block_given?
    begin
      yield(file)
    ensure
      file.close
    end
  end
end
```

Net::HTTP
```ruby
require 'net/http'

uri = URI('http://example.com')

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new(uri)

  response = http.request(request)
  p response
end

# The start method is implemented as follows:

def start
  if block_given?
    begin
      do_start
      return yield(self)
    ensure
      do_finish
    end
  end
  do_start
  self
end
```
