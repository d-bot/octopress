---
layout: post
title: "Ciphersuites"
date: 2014-10-07 22:11:21 +0000
comments: true
categories: 
---

When an SSL (or TLS) connection is established between a client and server they tell each other which ciphersuites they support and the order in which they prefer them. A ciphersuite is the triplet of symmetric encryption, public-key cryptography and HMAC algorithms used for SSL. Triplets must be specified because not all symmetric encryption, public-key cryptography and HMAC algorithms work with each other. Typically clients and servers will support many different ciphersuites but the one actually used will be the highest preferred by the server that is supported by both the client and server. If the client and server do not support a common set of ciphersuites the server will close the connection. The symmetric encryption and HMAC algorithms specified by themselves is called the CipherSpec.

ServerHello 메세지를 전달받은 클라이언트는 선택된 Ciphersuite 를 기초로 서버와 세션키를 공유하고 Application Data 를 암호화한다.
Ciphersuite 는 공개키, 대치키, 해쉬 알고리즘의 묶음으로 구성된다. 아래 항목은 SSL 프로토콜에서 대표적으로 제공하는 공개키, 대칭키, 해쉬 알고리즘이다. 보통 공개키, 해쉬 알고리즘은 세션키를 교환하기 위해 사용되며, 대칭키 알고리즘은 Application Data 를 암호화하기 위해 사용된다.

공개키 알고리즘: RSA, Diffie-Hellman
대칭키 알고리즘: RC2, RC4, DES, 3DES, IDEA, AES
해쉬 알고리즘: SHA, MD5

SSL 은 위와 같은 공개키, 대칭키, 해쉬 알고리즘을 하라로 묶어 아래와 같이 Ciphersuite 로 표현한다. 아래는 Ciphersuite 중에 하나를 예로 나타낸것이다. 아래 예제는 TLS 프로토콜 사용하고 RSA 를 공개키 알고리즘으로 DES 를 대칭키 알고리즘으로 사용하며 CBC 모드로 데이터를 암호화 하고 SHA 를 해쉬 알고리즘으로 사용하는 Ciphersuite 이다.

TLS_RSA_WITH_DES_CBC_SHA

만약 클라이언트와 서버가 handshake 프로토콜을 통해 위의 Ciphersuite 를 협의했다면 상호간에 전송되는 Application Data 는 DES 로 암호화되어 전송되게 된다.

