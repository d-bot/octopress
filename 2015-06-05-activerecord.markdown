---
layout: post
title: "ActiveRecord"
date: 2015-06-05 22:55:28 +0000
comments: true
categories: 
---

#### Create a table
```ruby
## After creating directory db/migration/
rake db:create_migration NAME=install_infos   # table name will be plural
## Table name will be InstallInfo (singular)

## Run
rake migrate:db
```

#### Add a new column
```ruby
rake db:add_zone1_zone2_column iemail:string
```ruby
```
```
