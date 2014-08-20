---
layout: post
title: "Interface"
date: 2014-08-20 05:03:08 +0000
comments: true
categories:
published: false
---
## Flexible Interface

인터페이스에는 2가지 종류가 있는데 하나는 다른 객체들에 의해 사용되는 public methods 들이고 다른 하나는 public methods 들에 의해 사용되는 private methods 들이다.

식당을 예로 들면 메뉴가 interface 에 속하고 주방에서 일하는 주방장들과 직원들은 private methods 들에 속하며 해당 interface 들이 주고 받는 "메세지" 들은 손님들이 알수 없고 알 필요도 없다.

## 어플리케이션 디자인

자전거 투어 회사 서비스

일단 Trip, Customer, Route, Bike, Mechanic 등의 명확한 물리적이고 behavior + data 를 가지는 명확한 객체들이 먼저 생각난다.

하지만 이들간에 주고 받는 메세지를 자세히 살펴보면서 명확하지 않은 객체들을 발견해 나가는게 중요하다. 즉, class-based design 에서 message-based design 으로 진행하는게 더욱 효과적이다.

### How vs What

### Context Independence (easier to test and re-use)

각 클래스들은 다른 클래스들의 interface 에 대해 독립적이어야 한다. (p106 이해가 안간다)

 a                         a
TRIP                    Mechanic
  |                        |
  |                        |
  |   Prepare_trip(self)   |
  |----------------------->--
  |                        ||
  |                        ||
  |       bicycles         ||
  --<------------------------
  ||                       |
  ||                       |
  ------------------------>--
  |                        ||
  |                |for each bicycle|
  |                        ||
  |                        ||
  |                        || prepare_bicycle(bike)
  |                        ||
  |                        ||
  <--------------------------
 a                         a
TRIP                    Mechanic


Trip 은 Mechanic 의 public interface 에 대해서 아는게 없지만 self 를 argument 로 넘기면서 원하는걸 해달라고 말하면 Mechanic 은 즉시 Trip 을 호출하여 자전거 리스트를 받아내서 자전거를 준비시킨다.


