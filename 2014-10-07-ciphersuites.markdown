---
layout: post
title: "Ciphersuites"
date: 2014-10-07 22:11:21 +0000
comments: true
categories: 
---

#### Ciphersuite: Symmetric encryption + publick key cryptography(asymmetric encryption) + HMAC algorithms

Ciphersuite 는 공개키(asymmetric), 대칭키(symmetric), 해쉬(HMAC) 알고리즘의 묶음으로 구성된다. 아래 항목은 SSL 프로토콜에서 대표적으로 제공하는 공개키, 대칭키, 해쉬 알고리즘이다. 보통 공개키, 해쉬 알고리즘은 세션키를 교환하기 위해 사용되며, 대칭키 알고리즘은 Application Data 를 암호화하기 위해 사용된다.

- 공개키 알고리즘 (혹은 비대칭키 알고리즘): RSA, Diffie-Hellman
- 대칭키 알고리즘: RC2, RC4, DES, 3DES, IDEA, AES
- 해쉬 알고리즘: SHA, MD5

SSL 은 위와 같은 공개키, 대칭키, 해쉬 알고리즘을 하나로 묶어 Ciphersuite 로 표현하고 아래는 Ciphersuite 중에 하나를 예로 나타낸것이다. 아래 예제는 TLS 프로토콜 사용하고 RSA 를 공개키 알고리즘으로 DES 를 대칭키 알고리즘으로 사용하며 CBC 모드로 데이터를 암호화 하고 SHA 를 해쉬 알고리즘으로 사용하는 Ciphersuite 이다.

```
TLS_RSA_WITH_DES_CBC_SHA
```

만약 클라이언트와 서버가 handshake 프로토콜을 통해 위의 Ciphersuite 를 협의했다면 상호간에 전송되는 Application Data 는 DES 로 암호화되어 전송되게 된다.

보통 클라이언트와 서버간 SSL/TLS 통신을 할때 서로 어떤 ciphersuites 를 어떤 순서(preferred order)로 어떤 ciphersuite 들을 지원하는지 서로 알려준다 왜냐하면 서버나 클라이언트에서 해당 암호화 방식들을 지원하는게 조금씩 다르기 때문이다. (보통 클라이언트가 지원하는 모든 ciphers 중 서버쪽에서 가장 preferred 하는 ciphersuite 가 선택된다)

The symmetric encryption and HMAC algorithms specified by themselves is called the CipherSpec.

ServerHello 메세지를 전달받은 클라이언트는 선택된 Ciphersuite 를 기초로 서버와 세션키를 공유하고 Application Data 를 암호화한다. (여기서 말하는 세션키는 서버로부터 받은 certificate 을 이용해서 symmetric key 를 암호화한것을 말하는듯)

#### HMAC Authentication

Symmetric encryption and public-key cryptography can make a message more difficult for an attacker to understand but they don't guarantee the integrity of the message. In other words an attacker may not be able to understand a message but he or she could still manipulate the encrypted message (e.g. by eliminating half of the message). SSL uses a combination of digital signatures and secure message digest algorithms to authenticate messages.
A digital signature takes advantage of the fact that while only a private key can decrypt something encrypted by a public key the opposite is also true. Something encrypted with a private key only can be decrypted by the corresponding public key. That might not sound too useful since everyone has access to the public key. However, if someone sends a message in cleartext and then sends the same message encrypted with the private key (i.e. signed), when the signed message is decrypted with the public key and it matches the message sent in cleartext the receiver can be sure the sender has access to the corresponding private key.
Clearly sending the message as cleartext first wouldn't be useful as that would defeat the purpose of encrypting the message. Obviously the sender could repeat the above procedure except instead of sending the first message as cleartext he or she could send the first message encrypted with public-key cryptography and then send a signed copy of the encrypted message. This would be very inefficient however. Every message would need to be sent twice (i.e. unsigned plus signed) and public-key cryptography is compute intensive.  One way to shorten the signed message is to use a message digest.
The simplest message digest algorithm is a checksum. For example, the ASCII values for the entire text of a message could be added up and the first n-bits could be taken to arrive at a number that would be significantly shorter than the text of the message. Unfortunately there are many different texts that could sum up to the same value using ASCII. These other texts that sum up to the same value are called collisions. The message digest should be unique (i.e. avoids collisions), deterministic (i.e. you get the same result every time you run it), and irreversible (otherwise the message could be derived from the digest).
There are several message digests algorithms available (e.g. MD5, SHA-1, SHA-256). While MD5 and SHA-1 are still commonly used they are no longer considered secure. SHA-256 is recommended. Each of them transforms the message in different ways but all of them are secure hash functions that attempt to produce unique and irreversible message digests. They also reduce fixed size chunks of the message (e.g. 512-bits for MD5) to smaller chunks (e.g. 128-bit hashes for MD5), add up the hashes, and take the first n-bits equal to the hash size (e.g. 128-bits for MD5) of the sum ignoring the rest (i.e. overflow is allowed). Thus the hash is usually significantly smaller than the original message.
Unfortunately the hash by itself isn't quite enough to assure that the message can't be derived from the message digest. Since the hash will produce the same output for the same input some outputs can be pre-computed from well-defined inputs (e.g. credit card numbers). In order to avoid such predictable outputs a shared secret must be added to the input before it is hashed. The hash of the secret and the message is called a Hash Message Authentication Code (HMAC).
After the receiver decrypts the message with the private key and runs it through the HMAC he or she compares the result to the HMAC result signed by the sender's private key. If they match, then the message is authentic. This authentication is done for every SSL record (~16k - 20k of data depending on the algorithm).
