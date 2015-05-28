---
layout: post
title: "Callback instead of return"
date: 2014-12-07 19:44:29 +0000
comments: true
categories: Ruby
---

함수를 작성할때 블럭을 파라미터로 받아서 return 대신 블락을 받아서 return 될 데이터를 블락으로 넘긴다. Client code 에서는 넘어온 데이터를 블락으로 평가하여 코드를 작성한다.

```ruby
def import_purchase(date, title, user_email, &import_callback)
	user = User.find_by_email(user_email)
	unless user.purchased_titles.include?(title)
		purchase = user.purchases.create(title: title, purchased_at: date)
		import_callback.call(user, purchase)	# user 와 purchase 를 callback 으로 넘긴다.
	end
end
```

Client code 에서는 import_purchase API 가 리턴한 데이터 user, purchase 를 이용하여 코드를 작성한다.
```ruby
import_purchase(date, title, user_email) do |user, purchase|
	send_book_invitation_email(user.email, purchase.title)
end
```

