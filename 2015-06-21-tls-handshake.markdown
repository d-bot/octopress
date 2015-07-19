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

--------------------------
Full Handshake

- 최초에 각 peer 들이 접속을 맺을때는 full handshake 가 일어나고 full handshake 가 발생할때는 다음과 같은 main activities 가 양쪽에 일어난다.
1. Exchange capabilities and agree on desired connection parameters.
2. Validate the presented certificate(s) or authenticate using other means.
3. Agree on a shared master secret that will be used to protect the session.
4. Verify that the handshake message haven’t been modified by a third party.

step2 and 3 are part of a single step called key exchange


SSL/TLS 에서 커넥션을 맺는것은 아래의 속성을 가지게 된다.

- Server Authentication - client can verify the server’s identity
- Client Authentication - Server can optionally verify the client’s identity. (client certificate)
- Encryption
- Integrity - Both peers can verify that the info was not tampered with



SSL/TLS utilizes 2 different stages:

Key Exchange
- In this stage, asymmetric cryptography is used to exchange a symmetric key for later communication as well as authenticate the peers.
- This occurs during a phase of the session known as the Handshake
- CPU cost of performing asymmetric cryptography is generally very high)

Bulk Encryption
- this stage is used for the actual sending of data and represents the vast majority of the session.
- uses the symmetric key negotiated during the handshake
- once key exchange has occurred, we remain in this stage until connection termination or renegotiation occurs

SSL/TLS Key Exchange

- There are multiple key exchange methods out there but most of people think RSA 
- The handshake at the beginning of a session determines which is used.
- Most common by far is RSA which uses asymmetric crypotygraphy and certificates signed by trusted third parties like Comodo, Cybertrust etc

- Signing involves taking a hash(md5sum, sha1sum, these days sha2sum) of the source material and encrypting it with the private key
- Authenticity and integrity is verified by rehashing the source material and comparing the value to the result of decrypting the singnature with the public key


TLS Handshake

1. 클라이언트(브라우저)가 랜덤넘버를 특정 entrophy 값들을 바탕으로 생성한다. 그리고 해당 랜덤 넘버와 클라이언트가 서포트하는 사이퍼들을 우선순위(cipher list ordered by priority)로 하여 해당값들을 포함하는 clienthello 메세지를 생성하여 서버에 전달한다. (예를 들면 I support these key exchange methods and I support following ciphers and following hash mechanism(md5 sha1) I support compression et cet era) 이런 정보를 over TCP 로 전송하면 서버가 거기서 hash 알고리즘이나 싸이퍼를 pick한다.

2. 서버는 클라이언트 랜덤 번호를 기록하고, 클라이언트가 보낸 사이퍼 리스트들과 옵션들을 보고 셋오브 싸이퍼를(cipher suite) 선택한다. 예를 들면 RSA for key exchange, AS256 for bulk encryption cipher and sha1 for integrity check. 그리고 서버도 랜덤 넘버생성해서 선택한 ciphersuite 를 서버헬로  메세지에 포함하여 보내주고,
다시 서버 인증서를 보낸다. (2번 메세지를 보내는거임) 지금까지 주고받은 메세지로 각 peer 들은 server random 과 client random 넘버를 서로 가지고 있다 아래와 같이.



3. 클라이언트는 서버로부터 받은 인증서를 검증하고 서버의 public key 를 추출해 내서 저장한다. 그리고 서버는 handshake 에서 가장 불필요한 메세지인 ServerHelloDone 메세지를 보낸다.

4. 이시점에서 클라이언트는 랜덤 자이안트 밸류(big box of bits)로된 Pre-master secret 을 생성한다. (최대한 랜덤한 밸류여야한다.) 아시다시피 이 핸드쉐이크의 궁극적인 목적은 bulk encryption 에 사용될 symmetric key 을 서버에 전달하는것이다. (symmetric key 는 PRF function 을 이용해서 생성하는데 해당 함수는 server random, client random and pre-master secret 을 인자로 받는다 - loosely based on HMAC)

근데 클라이언트는 symmetric key 를 생성할 모든 정보와 데이터가 있으나 서버는 pre-master secret이 현재 없다 그리고 지금까지 보내고 받은 데이터들은 plain text 라 pre-master secret 까지 그렇게 보내면 의미가 없으므로 asymmetric key 즉,  pre-master secret 을 서버의 public key 로 암호화하여 보낸다.

5. 이렇게 암호화된 pre-master secret 을 받은 서버는 자신의 private key 로 복호화하여 pre-master secret 을 알아내고 마침내 양쪽 모두 client random, server random 그리고 pre-master secret 을 모두 가지게 된다. 그리고 PRF function 을 통해 해당 server random, client random and pre-master secret 값들을 파라미터로 받아 몇번의 해슁을 통해 (자세한건 TLS RFC 참조) symmetric key 를 마침내 양쪽 모두 생성한다. At this point, we can enter the bulk encryption phase.

6. 마지막으로 서버한테 지금부터 해당 symmetric key 를 통해서 통신할거라고 ChangeCipherSpec 메세지를 통해서 알려준다. 그리고 finished 메세지 (which is hash of all prior messages)를 서버에 보낸다. (예전에는 누군가 client hello 메세지에 지원하는 cipher가 없는것으로 서버에 메세지를 보내서 서버쪽에서도 아무 cipher 를 선택하지 않아 전혀 암호화가 되지 않는 버그가 있었음: cipher downgrade attack)

7. 서버는 자기가 클라이언트에게 지금껏 보낸 메세지들을 해슁해서 클라이언트로 받은 finished 메세지와 비교해 본다. 이것은 bulk encryption stage 로 들어가기전 누군가 중간에서 메세지를 변조하지는 않았는지 마지막으로 점검하는 단계이다. 

8. 서버는 클라이언트로 받은 finished 메세지를 보고 자신이 보낸 모든 메세지들을 비교해보고 모두 일치하면 I now too agreed upon the symmetric key to use 라는 CipherChangeSpec 메세지를 보내고 클라이언트에게 finished 메세지 (Here’s my ciphers that I’ve seen so far) 를 보내면서 full handshake 가 종료된다.



Problem Statement

- OK to terminate SSL session but not enough to have the private key
- Compromised 되더라도 private key 가 유출되지 않을것이다. (They couldn’t hurt the network after theft)

private key 만 서버에 없다면 케이지가 있던 모션 디텍팅을 하던 말던 상관없음. terminated SSL session can live on a server for a week as long as there is no private key. 세션이 하이젝되면 해당 세션의 유저들만 피해가 가지만 키가 유출되면 전체 고객의 정보가 유출되는거임.

OCSP, CRL 은 private key 가 유출되는것을 막기 위한 기능이나 많은 브라우저들이 사용하지 않음.

사실, private key 는 TLS handshake 에서 딱 한번 사용된다. 클라이언트로 부터 받은 암호화된 pre-master secret 을 복호화할때 한번 사용된다. 즉, keyless SSL 을 achieve 하기 위해서는 SSL session terminate 하는 서버들 (for SSL session terminator)

So, can we split that apart?

private key 가 유출되면 해당 키로 사인된 인증서들은 모두 CRL 이나 OCSP 서버에 등록되어야 한다.



session re-negotiation uses session resumption which requires only server random number?


Full Handshake

- 최초에 각 peer 들이 접속을 맺을때는 full handshake 가 일어나고 full handshake 가 발생할때는 다음과 같은 main activities 가 양쪽에 일어난다.
1. Exchange capabilities and agree on desired connection parameters.
2. Validate the presented certificate(s) or authenticate using other means.
3. Agree on a shared master secret that will be used to protect the session.
4. Verify that the handshake message haven’t been modified by a third party.

step2 and 3 are part of a single step called key exchange


SSL/TLS 에서 커넥션을 맺는것은 아래의 속성을 가지게 된다.

- Server Authentication - client can verify the server’s identity
- Client Authentication - Server can optionally verify the client’s identity. (client certificate)
- Encryption
- Integrity - Both peers can verify that the info was not tampered with



SSL/TLS utilizes 2 different stages:

Key Exchange
- In this stage, asymmetric cryptography is used to exchange a symmetric key for later communication as well as authenticate the peers.
- This occurs during a phase of the session known as the Handshake
- CPU cost of performing asymmetric cryptography is generally very high)

Bulk Encryption
- this stage is used for the actual sending of data and represents the vast majority of the session.
- uses the symmetric key negotiated during the handshake
- once key exchange has occurred, we remain in this stage until connection termination or renegotiation occurs

SSL/TLS Key Exchange

- There are multiple key exchange methods out there but most of people think RSA 
- The handshake at the beginning of a session determines which is used.
- Most common by far is RSA which uses asymmetric crypotygraphy and certificates signed by trusted third parties like Comodo, Cybertrust etc

- Signing involves taking a hash(md5sum, sha1sum, these days sha2sum) of the source material and encrypting it with the private key
- Authenticity and integrity is verified by rehashing the source material and comparing the value to the result of decrypting the singnature with the public key


TLS Handshake

1. 클라이언트(브라우저)가 랜덤넘버를 특정 entrophy 값들을 바탕으로 생성한다. 그리고 해당 랜덤 넘버와 클라이언트가 서포트하는 사이퍼들을 우선순위(cipher list ordered by priority)로 하여 해당값들을 포함하는 clienthello 메세지를 생성하여 서버에 전달한다. (예를 들면 I support these key exchange methods and I support following ciphers and following hash mechanism(md5 sha1) I support compression et cet era) 이런 정보를 over TCP 로 전송하면 서버가 거기서 hash 알고리즘이나 싸이퍼를 pick한다.

2. 서버는 클라이언트 랜덤 번호를 기록하고, 클라이언트가 보낸 사이퍼 리스트들과 옵션들을 보고 셋오브 싸이퍼를(cipher suite) 선택한다. 예를 들면 RSA for key exchange, AS256 for bulk encryption cipher and sha1 for integrity check. 그리고 서버도 랜덤 넘버생성해서 선택한 ciphersuite 를 서버헬로  메세지에 포함하여 보내주고,
다시 서버 인증서를 보낸다. (2번 메세지를 보내는거임) 지금까지 주고받은 메세지로 각 peer 들은 server random 과 client random 넘버를 서로 가지고 있다 아래와 같이.



3. 클라이언트는 서버로부터 받은 인증서를 검증하고 서버의 public key 를 추출해 내서 저장한다. 그리고 서버는 handshake 에서 가장 불필요한 메세지인 ServerHelloDone 메세지를 보낸다.

4. 이시점에서 클라이언트는 랜덤 자이안트 밸류(big box of bits)로된 Pre-master secret 을 생성한다. (최대한 랜덤한 밸류여야한다.) 아시다시피 이 핸드쉐이크의 궁극적인 목적은 bulk encryption 에 사용될 symmetric key 을 서버에 전달하는것이다. (symmetric key 는 PRF function 을 이용해서 생성하는데 해당 함수는 server random, client random and pre-master secret 을 인자로 받는다 - loosely based on HMAC)

근데 클라이언트는 symmetric key 를 생성할 모든 정보와 데이터가 있으나 서버는 pre-master secret이 현재 없다 그리고 지금까지 보내고 받은 데이터들은 plain text 라 pre-master secret 까지 그렇게 보내면 의미가 없으므로 asymmetric key 즉,  pre-master secret 을 서버의 public key 로 암호화하여 보낸다.

5. 이렇게 암호화된 pre-master secret 을 받은 서버는 자신의 private key 로 복호화하여 pre-master secret 을 알아내고 마침내 양쪽 모두 client random, server random 그리고 pre-master secret 을 모두 가지게 된다. 그리고 PRF function 을 통해 해당 server random, client random and pre-master secret 값들을 파라미터로 받아 몇번의 해슁을 통해 (자세한건 TLS RFC 참조) symmetric key 를 마침내 양쪽 모두 생성한다. At this point, we can enter the bulk encryption phase.

6. 마지막으로 서버한테 지금부터 해당 symmetric key 를 통해서 통신할거라고 ChangeCipherSpec 메세지를 통해서 알려준다. 그리고 finished 메세지 (which is hash of all prior messages)를 서버에 보낸다. (예전에는 누군가 client hello 메세지에 지원하는 cipher가 없는것으로 서버에 메세지를 보내서 서버쪽에서도 아무 cipher 를 선택하지 않아 전혀 암호화가 되지 않는 버그가 있었음: cipher downgrade attack)

7. 서버는 자기가 클라이언트에게 지금껏 보낸 메세지들을 해슁해서 클라이언트로 받은 finished 메세지와 비교해 본다. 이것은 bulk encryption stage 로 들어가기전 누군가 중간에서 메세지를 변조하지는 않았는지 마지막으로 점검하는 단계이다. 

8. 서버는 클라이언트로 받은 finished 메세지를 보고 자신이 보낸 모든 메세지들을 비교해보고 모두 일치하면 I now too agreed upon the symmetric key to use 라는 CipherChangeSpec 메세지를 보내고 클라이언트에게 finished 메세지 (Here’s my ciphers that I’ve seen so far) 를 보내면서 full handshake 가 종료된다.



Problem Statement

- OK to terminate SSL session but not enough to have the private key
- Compromised 되더라도 private key 가 유출되지 않을것이다. (They couldn’t hurt the network after theft)

private key 만 서버에 없다면 케이지가 있던 모션 디텍팅을 하던 말던 상관없음. terminated SSL session can live on a server for a week as long as there is no private key. 세션이 하이젝되면 해당 세션의 유저들만 피해가 가지만 키가 유출되면 전체 고객의 정보가 유출되는거임.

OCSP, CRL 은 private key 가 유출되는것을 막기 위한 기능이나 많은 브라우저들이 사용하지 않음.

사실, private key 는 TLS handshake 에서 딱 한번 사용된다. 클라이언트로 부터 받은 암호화된 pre-master secret 을 복호화할때 한번 사용된다. 즉, keyless SSL 을 achieve 하기 위해서는 SSL session terminate 하는 서버들 (for SSL session terminator)

So, can we split that apart?

private key 가 유출되면 해당 키로 사인된 인증서들은 모두 CRL 이나 OCSP 서버에 등록되어야 한다.



session re-negotiation uses session resumption which requires only server random number?



