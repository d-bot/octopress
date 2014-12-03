---
layout: post
title: "TLS Handshake"
date: 2014-09-21 17:19:41 +0000
comments: true
categories:
---

```
Client: TCP SYN

Server: TCP SYN+ACK

Client: TCP ACK & TLS Hello			# Starting TLS handshake

Server: TLS Hello & Server Key

Client: TLS Ack & Server Key check & Client Key Exchange

Server: TLS Handshake done

Client: HTTP Request (GET)			# Starting HTTP

Client: HTTP Respond

```

#### HTTP 는 두번의 round-trip 이면 되지만 HTTPS 는 http request 를 보내기 위해서 4번의 round-trip 이 필요하다.


There are two main types of handshakes in TLS: one based on RSA, and one based on Diffie-Hellman. RSA and Diffie-Hellman were the two algorithms which ushered in the era of modern cryptography, and brought cryptography to the masses. These two handshakes differ only in how the two goals of key establishment and authentication are achieved

---
#### RSA: Rivest, Shamir, Adleman (RSA 암호법 만든 사람이름)

문제는 양쪽이 한개의 비밀키를 같이 사용하는게 문제 (대칭키: Symmetric). 즉, 키를 전달할 필요 없이 양쪽이 각각 개인키와 공개키 쌍을 만들어서 공개키를 공유하고, 공개키를 이용해서 암호화된 내용은 개인키를 이용해서만 복호가 가능 => 비대칭키/공개키 방식(Asymmetric)

위의 방법은 리소스를 많이 사용하므로 위의 공개키 암호화 방식은 대칭키를 보내는 용도에만 사용한다. 즉, 대칭키 문제는 암호화/복호화가 쉽지만 앞서 말한바와 같이 키를 공유하는 과정에서 누출이 될수 있는 문제가 있었는데, 공개키 방식을 "대칭키 전달 용도"로만 사용하는게 현재의 SSL/TLS 방식.

```
client ------------------------------------------------> Server
                       Client Hello

client <------------------------------------------------ Server
               Server Hello & Send public key

client ------------------------------------------------> Server
           암호화할때 사용할 대칭키(symmetric key)를
      서버로부터 받은 공개키를 이용해서 암호화하여 보낸다

client <------------------------------------------------ Server
           서버는 개인키로 복호화해서 대칭키를 알아냄

client <------------------------------------------------> Server
          대칭키를 이용해서 암호화된 내용을 주고받음
```

자 그럼 여기서 해당 서버가 주는 public key 를 어떻게 신뢰할수 있는지에 대한 의문이 생기고 여기서 Symantec, Comodo, Geotrust, Digicert, Cybertrust 같은 기관들이 신뢰를 심어주겠다며 돈받고 certificate signing 비즈니스를 아래와 같이 하고 있음.

1. Client 는 private key 와 그와 짝을 이루는 public key (CSR)을 만들어 인증기관에 제출
2. 인증기관은 domain validation 이후 CSR 을 해당 인증기관의 private key로 암호화한다. 이것이 ssl certifiacate
3. 인증기관은 모든 웹브라우저 벤더들에게 자신의 공개키를 뿌려서 기본적으로 탑재하도록 한다.
4. 이제 end-user 가 해당 웹사이트에 접속하면 인증기관이 사인한 certificate 를 서버로부터 내려 받는다.
5. 인증기관으로부터 받은 공개키가 브라우저에 있으므로 해당 certificate 를 복호화하여 웹사이트 검증. (match CN)
6. 이렇게 얻은 사이트 공개키 (CSR) 을 이용해서 앞으로 통신에 사용할 "대칭키"를 암호화해서 서버에 전송.
7. 해당 사이트 서버는 자신의 private key로 암호내용을 복호화해서 해당 "대칭키"를 알아내서 앞으로 통신에 사용.

