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



Client Hello

일반적으로 SSL/TLS 트러블슈팅시 가장 먼저 중요하게 봐야할 부분은 client/server hello 패킷임. 일단 client/server hello 패킷은 RFC 5246, 41페이제에 아래와 같이 잘 정의되어 있고 각 섹션은 handshake negotiating 과정에 있어서 모두 중요하다.
```
      struct {
          ProtocolVersion server_version;
          Random random;
          SessionID session_id;
          CipherSuite cipher_suite;
          CompressionMethod compression_method;
          select (extensions_present) {
              case false:
                  struct {};
              case true:
                  Extension extensions<0..2^16-1>;
          };
      } ServerHello;
```

1. Version Number: 예전엔 그다지 중요하지 않았음. 해당 버전은 클라이언트가 서버로 보내면 서버는 자신이 지원하는 버전보다 낮을 경우 클라이언트지원하는 버전에 맞출때까지 자신의 프로토콜 버전을 다운그레이드 한다. 요즘에 특히 POODLE 이후로는 클라이언트의 버전이 너무 낮을 경우 서버는 자신의 프로토콜 버전을 다운그레이드하지 않고 접속을 종료시켜 버린다.
2 = SSL 2.0,
3 = SSL 3.0
3.1 = TLS 1.0
3.2 = TLS 1.1
3.3 = TLS 1.2

2. Random Number: 해당 값은 pre-master secret 을 만드는데 중요하다.

3. Session Identification: 해당 필드는 이미 접속했던 유저가 이전 접속시 사용했던 certificate 과 프로토콜 버전으로 재접속(resume)을 원할때 서버쪽에서는 이전에 해쉬해놓은 세션ID 를 재사용해서, Server/Client Hello 패킷교환 이후에 필요한 handshake 작업들을 많이 생략하도록 한다.

4. Cipher Suite: Type of encryption that we’ll going to be using for the ssl handshake. It also tells us what type of key exchange we’re gonna do. Previously when the cipher suite was created at the beginning like 2000 0 3.0, they weren't very descriptive and the cipher suites were very short but these days the new cipher suites that are added on, especially like ~~~ they’re pretty detailed. they’ll have actual CipherSuite_KeyExchange_HashFunction_~~~ the cipher suite actually is very long these days because it tries to be as descriptive as possible.

5. Compression Algorithm: Not useful at all. There is no compression happens because RFC does not define any compression. That’s not true. It actually defines one compression which is NULL. And that is the compression suite that everybody uses.

6. Extensions: This section is extendable in terms of it doesn’t have very defined structure. Client will send a TLS extension to the server telling it the additional capability that it can handle. For instance, if the client can do the secure re-negotiation, it will actually send a TLS extension saying that I can do secure re-negotiation. This is important because the server cannot send back a confirmation of the additional feature in TLS handshake unless the client initially says I can support this. So your web server can do the secure-renegotiation but if the client says he can’t do it, it will never send that feature to client in its reply. So the client always has to tell the server what  features it wants. If he wants OCSP stapling, this client hello packet has to have inside TLS extension says I want to have OCSP stapling inside the certificate that you’re gonna send me. Even though we can figure the OCSP stapling on our web server, we’ll not send OCSP stapling to the client unless the client says I can actually support OCSP stapling.


Cipher Suites and Signaling Ciphers

Typical cipher suite: SSL_RSA_WITH_DES_CBC_SHA
SSL: protocol version
RSA: key exchange algorithm
DES_CBC: encryption algorithm
SHA = hash function

위의 CipherSuite 는 PCI compliance 를 만족시키지 못함. PCI compliance 가이드라인에 의하면 가장 secure 한 프로토콜을 사용하도록 권장하는데 현재로서는 TLS 1.2 

Real example from wireshark: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
TLS: protocol version
ECDHE_RSA: key exchange algorithm
AES_128_CBC: encryption algorithm
SHA256: hash function

Signaling Cipher Suite Value: (SCSV) This is kind of a new thing that was put in place not too long ago. It's called SCSV for short. So what happens client sent TLS extensions that server doesn’t understand? The server is supposed to ignore the extension but it looks some web servers got killed if they don’t understand the extensions.

When secure re-negotiation was decided to be made a (scene) that has to be supported, people weren’t sure that server could understand the secure re-negotiation that was not part of the standard when the web servers were built. So what they did was they actually put a cipher suite looking cipher signal inside the cipher suite that will let it know that it can do the secure re-negotiation so instead of SSL_RSA_WITH_DES_CBC_SHA, it will say something like secure_re-neg and put that cipher suite inside with all the other cipher suites and so basically it understand that we would have to go to your web server, to understand that not only you look for the cipher suite but also you have to look for the signaling cipher suite. and if the signaling cipher suite is basically not equivalent to a TLS extension so once we get the certain signaling cipher suite, we can tell that the client can support secure re-negotiation function.

So the client expect the server to advertise that strings cipher suite?

Let say if the client can understand secure re-negotiation, once do secure re-negotiation, it basically it doesn’t have to send TLS extensions anymore as the only option. It can actually send the signaling cipher suite within the cipher suite algorithm packet 
 
If it gets TLS extension it doesn’t understand, it’s supposed to just disregard it but some of the old web servers don’t do that. They just got killed.

So what happens is the server is supposed to go through all the list of cipher suites that the client has so it can pick and choose which one it wants. Because it has to traverse all the cipher suites it will actually see that signaling cipher suite somewhere inside the packet. and so once it sees that it knows that it’s not part of cipher suite but that this is the signaling cipher suite so it should turn on a certain type of TLS extension that the signal cipher suite is supposed to turn on.

Server Hello

Version Number: The server version is the client version if it is supported by the server. else the highest version supported by the server. If server supports a higher version than client and protocol downgrade not allowed then handshake fails.

Random Number: same as client’s random number.

Session Identification: Client sends session id in client hello saying I want to reuse this session, if the server still has the session id inside of its session cache, it will send back the session cache id to client. If the session id is no longer in the cache, server doesn’t send session id and client will start full TLS handshake all over again. If client gets the session id, client will perform an abbreviated handshake. (Session id is basically to confirm for client whether it can or cannot resume the session)

Cipher Suite: Server will then basically pick one cipher out of the client cipher list on how it want to do the encryption and key exchange. Server doesn’t send its ciphers that he supports. It only pick one cipher out of the client cipher list.

Compression Algorithm: RFC only defines only one which is NULL

Extension: It will send back extensions seen in the client hello that the server can support out of the client’s extension list. Server cannot add TLS extension that client doesn’t sent

Server Certificate: This is the public key that we send to the client and this is what client asks for when it connects to SSL. Previously we used to have a248. That was signed by a root CA. The cert was only 1024 bits so the reason why we did that for FF was it actually gave us a performance increase over our competitors. We were one of 2 companies of whole world that basically had that root signed CA. With a root signed CA, we basically did not have to send any intermediates along with the cert when we send to the client. So it basically has a smaller packet size. And because it was the off standard 1024bit cert, it was enough to send the entire certificate in a single packet. These days we cannot do that anymore. The CAs got together and they've all agreed that no CA will ever sign anything directly from the root itself ever. Now you have to have intermediates. Now the new national standard for america is cert has to be 2048 bits now. So with the 2048 bit cert and intermediates we went from a single packet to 3 packets so now we have to send 3 packets for the server cert while we used to send one packet. We are no longer have this little advantages we used to have.


Server Key Exchange(RSA): This is basically where all the CPU comes from. When they decide how to do the key exchange. It has 2 options. The old option what we're currently using right now is RSA . So with the RSA option, what happens is we send the server certs to the client and RSA key exchange here is usually empty. It’s blank. We don’t usually send the key exchange this field is normally used when it’s also mainly because we used to have server certs that were left 1024. We used to have 256 and 512bit SSL certs way back then. And that was actually not enough data to generate a pre-master master key and session key so based use this key exchange server use had extra data to build those keys but we don’t use that these days because the certs are above 512 bits and this field is not used anymore.

Previously we did not do  DH key exchange. The problem with DH key exchange is, it is very CPU intensive compare to RSA. It takes about 3 times longer in terms of speed to do DH key exchange versus RSA. So unless you have a huge infrastructure to do the DH key exchanges, everybody want to send RSA. We’ll talk about little bit more about DH later on because DH is what we actually use for PFS now. It’s now feasible to use DH versus RSA with electric curve.

Client Certificate Request: This is an optional step. This is basically for new xxx exchange. The server itself actually go back to the client and tell it. Can you send me your SSL cert as well. It’s gonna send you a server cert but the server now wants the actual SSL cert from the client. So typically you’ll see this with customers who has PKI infrastructure. A lot of our government customers have this infrastructure in place where it cannot access the government sites unless you’re some type of government employee and so to ensure the government employee’s all of the laptops or any devices have SSL certs on the devices. So when you contact Akamai, Akamai will then ask. Give me your government employee public key that’s very specific to your machine. This is in place actually to make that request.

After that, it’s done.

Server Hello Done: Simple message that basically tells client it waiting on them now.



Client Offline Verification

What does the client actually do once it gets the server hello? It goes through the validation process. It’s all documented in RFC. It gets the public key from the server so first thing it does is
 
1. Has the cert expired? Traverse the SSL chain.
2. Next thing it checks is, is this certificate signed by a trusted CA that is inside trusted database. Depending on the trusted databases, we have a lot of issues with Japanese phone and old Android machines that has very limited or old trusted databases. Now when these new EV certs came out, a lot of old Android did not understand these EV certs. These days, most of our issues are in Japan. Japan has very very old cellphones and they absolutely refused to update them. So we’re actually not even allowed to do TLS protocol in Japan for a lot of our Japanese customers because they can only support SSL. When we turned off SSLv2 and v3, it broke a lot of Japanese customers and we had to basically turn them back on again. To these days, we still have a lot of SSL mainly for Japan.

3. Does the domain name in the server’s certificate match the domain name of the server itself? (Not a part of the SSL handshake but always implemented)

3. Basically it does whole bunch of validation. We want to make sure the server certs getting is the actual cert that you’re requesting. So it does signature check and it does revocation check.

About revocation check
Basically you wanna see if the certificate has been revoked or not. There are 2 main ways to do it. The old way was the CRL so what CRL does is the client browser or client machine would actually go out to the internet based on the url that was inside the ssl cert it will go to the CA that issued that cert and pull down the actual file(DER encoded file(.crl) that contain the serial numbers of all bad (both valid and invalid expirations) SSL certs that were issued by that CA). That file will basically have the list of every single cert that was revoked. So as you can imagine, as time goes on, the file got bigger and bigger and require more and more time for the client to download this file. So that was a performance bottleneck. So they came up with this new method call OCSP. OCSP doesn’t download file. What it does is, it actually sends http get request or post request to the CA now and the CA will then have to do the validation for the client and send back either pass or fail saying whether this basically good or bad. That sounds great in theory but when we turned it on it was bad mainly because the CAs will not ready to handle all of these requests coming in and pounding their servers asking for validation. So a lot of the time what happened was when OCSP servers got this request it will basically take a long time for the OCSP server to get back to response. When we first turned it on we killed a lot of OCSP servers that were hosted by CA. They weren’t our customers other than our partner issuing the SSL certs but because of this we were able to get them to sign up for some services but mainly we gave free services where we front-ended akamai in front of their OCSP servers and it was for our benefit to do this. We couldn’t allow their OCSP server goes down all the time.

Client Response to Server Hello

Client Certificate (if requested)
If the server asks for a cert to the client then client sends the client cert to the server. If the server asks a cert but client send nothing. The client will actually send NULL, then the server can decide whether to continue with SSL connection or not. We have configured to do both. We have customers to say we don’t have client cert that’s fine we’ll just mark it down and log that you didn’t have the client cert and continue with the ssl session. Or the customers like government customers will say no. No client cert, we’ll kill your connection for now. This can be setup on any web servers. 

Client Key Exchange(RSA)
After the client gets the public key, it can actually now do encryption with the public key and so CPU spend on the client now to do encryption for the client key exchange if it’s RSA. So this is where we start using CPU time on the client side. the client now has with the randomly generated data from client,  the public key from the certificate and randomly generated data from the server side and now has enough data to generate the thing called the pre-master secret key. The pre-master secret key is then generated by the client encrypted and send back to the server so this pre-master key is basically encrypted and send to the server and it’s gonna be used. Once the pre-master key is available on both side, it now has enough data to generate a master key from he pre-master key. With the master key then it generates a session key. This is what the protocol standard requires to do. So it goes from the pre-master secret key to a master key to a session key. This session key is a symmetric key then be used to do all of the encryption and decryption when the client and server eventually talk and communicate with each other.

Client Key Exchange(DH)
Mathematically computes the DH algorithm and sends "public value” to the server: g^b mod p=B
(p stands for very large prime number that it uses to generate the public value and this public values are what it’s gonna use later on to actually generate pre-master key on the server itself as well. So if you recall back on the server hello, if this was a DH key exchange, the server has already generated a public value as well during the server key exchange. So if this was not RSA but DH key exchange all the way through the CPU on the server side are already start being used up right here when you generated key exchange during the DH key exchange.

Q: Do we use the DH in SSL? 
A: We try not to. If we do, it takes 3 times to processing it does for RSA. Unless the client specifically restricted those ciphers to only use DH key exchange ciphers, we always use RSA. If we didn’t, we basically have to add a lot more servers to ssl network to handle that amount of traffic we handle right now to do DH key exchange. Also the client’s CPU will eat up all the resources on their side.

Both client and server

After the pre-master is sent to and now on both side, both the client and the server do this at the very same time. If it’s RSA, the client and the server then use the pre-master key to generate the master key. If it’s DH, the client and server now have the public values from both side and with those public values that they both have, they can now generate their own pre-master key simultaneously on both side. So the pre-master key is now no longer exchanged between the two. This is important because this is why we have the PFS one of the thing is, what's FS is you’re scared that someone will figure out what the pre-master secret key is if we ever decommission the server, and we basically send the server to  somewhere and someone got our server and the disk with the private key, they can reverse engineer to get the pre-master key. With that pre-master key they can now generate their own master key and session key and any data they captured prior to this is now crackable.

With DH, the pre-master key is never sent across the wire these public values are. And the pre-master key is now separately generated on the server and on the client themselves. Master key is generated and session key is generated. and the due fall thing is, because these public value can keep changing we can now keep rotating the session keys. So even if somebody oneday captured the packets in DH and somehow managed to break those public values and then to generate pre-master key, master key and session key, they can only decrypt the session, one session that they captured because the session key is always be different now because we can generate always random public values. And that’s the advantage of having FS versus the RSA.

We use 2048bit key in RSA the equivalent key size for DH is 256 only. With the 256 elliptical curve key, we have an equivalent strength to RSA 2048 key. And the reason why we have this performance gain, with the elliptical curve we have smaller key size. with the smaller key size, we can generate keys faster because the key size is smaller but even though DH is now faster but because they always take 3 times longer to do the processing. It actually turns out to be very equivalent in terms of performance a RSA 2048 and the DH elliptical curve key with 512 bits in it. Even though you hear a lot of talk that says elliptical curve is very fast, it’s way to go because it’s so much faster it’s actually not faster it’s equivalent both in terms of the strength and speed because the DH previously took 3 times longer to process so even though you have all this additional speed now, it actually matches up pretty much equal now to in terms of performance wise with RSA. 
FS is exclusive only for DH


Client Final Handshake Response

After that session key is generated, both side has same key, it can now basically can do your get request. So the last thing client needs to send a final packet to the server says I’ve calculated the session key I’m ready to change ciphers. That’s what the change cipher spec is. Basically it says I finished all my calculations and I got the key, I’m ready to go and it sends it. And client sends changecipherspec and it uses that session key encrypts little data of the conversation in the client finished just to ensure that the server want the server gets this changecipherspec and client finished it can decrypt it. Once the server gets the 2 packets, it will send back to the client saying, you changed your cipher spec I finished my calculation as well and sends the change cipher spec message and does little hashes as well with the session key and sends that to client. And the client then use the session key to decrypt that little hash message.

You’ll always see the change cipher spec message and that change cipher spec message is the very last message you should see right before everything gets encrypted and your tcpdump looks like a garbage.



기본적으로 FULL TLS 핸드쉐이크는 3번의 RTT가 필요한데, 세션을 resume 하는 경우에는 2번만 필요. 근데 구글에서는 TLS ONE RTT HANDSHAKE 를 지원한다. 대략 아래 오른쪽 그림에서 5,6,7 패킷을 합쳐 한번에 보내면서 GET 리퀘스트를 넣어 보낸다. 그러면 서버는 8,9 패킷들을 보내면서 GET 리퀘스트에 대한 응답을 보내기 시작한다.




OCSP Stapling

SSL cert 가 valid 한지 확인을 하는 작업은 퍼포먼스를 저하시키므로 서버가 클라이언트를 대신해서 주기적으로 해당 cert 가 valid 한지 OCSP stapling 을 통해서 확인해줄수 있다.

During the server hello packet exchange, 응답하는 서버가 CA의 OCSP 서버로부터 OCSP 첵을 하여 해당 certificate 는 이미 OCSP 서버로부터 확인된 certificate 이라고 응답을 주는것. OCSP stapling 은 server hello 패킷의 스탠다드가 아니기때문에 OCSP staple response 를 client 에게 전달하기 위해서는 client 가 해당 메세지를 이해해야하는데 그럴려면 client 는 client hello 패킷을 보낼때 status_request extension 을 포함 시켜야 한다.

요즘은 intermediate certs 들이 server cert 와 함께 client로 전송되는데 문제는 web server 는 intermediate certs 에 대해서 OCSP stapling 을 해줄수 없기 때문에 client 는 여전히 CA 의 OCSP 서버에게 가서 해당 intermediates 가 valid 한지 확인을 해야한다. 왜냐하면 intermediates 는 trusted db 에 없기 때문에. 즉, 아주 조금의 퍼포먼스 향상이 OCSP stapling 을 통해서 이뤄지지만 결국 client 는 여전히 CA 의 OCSP 를 통해 intermediates 의 validity 를 확인해야하므로 별 차이가 없다. 이부분을 개선하려고 하는데 working group 쪽에서는 해당 아이디어를 안좋아함. Multi OCSP stapling. 


2013/2014 에 추가된것 Signaling Cipher Suite: 보통 이런것들은 특정 이슈들에 의해서 급하게 추가되는 경우인데 모든 브라우저들이 먼저 해당 cipher suite 를 지원하도록 업데이트가 되어서 client hello 패킷에 해당 signaling cipher suite 을 넣기 시작한다. 당연히 서버는 해당 signal cipher suite 을 이해하고 client hello 를 보낼때 extension section 에다가 해당 signal cipher suite 의 응답을 넣어 보낸다(원래 extension 이니까)

RFC 5746 - TLS renegotiation Indication Extension (TLS_EMPTY_RENEGOTIATION_INFO_SCSV): Tells the server that client supports secure renegotiation.

POODLE attack - TLS Fallback Signaling Cipher Suite Value(SCSV) for preventing protocol downgrade attacks(TLS_FALLBACK_SCSV): The connection should only be established if the highest protocol version supported on the server is identical to or lower than that of what it sees in the “version number” (즉, 서버가 TLS_FALLBACK_SCSV cipher suite 를 client hello 패킷에서 확인하면, 서버는 TLS 버전을 다운그레이드 하지 않음. POODLE 공격이 TLS protocol 을 SSL 로 다운그레이드 시키는 공격임)

PFS 관련해서는 아래 링크에 매우 자세히 low level 까지 설명이 잘되어 있음.
http://vincent.bernat.im/en/blog/2011-ssl-perfect-forward-secrecy.html

RSA vs DH performance comparison
https://securitypitfalls.wordpress.com/2014/10/06/rsa-and-ecdsa-performance/

아직 잘 이해는 안되지만 RSA key exchange 를 사용하려면 certificate 도 RSA 알고리즘으로 싸인이 되어야 하고 DH key exchange 를 사용하려면 certificate 도 역시 DH 알고리즘으로 싸인이 되어야 함. 현재 symantec 이 DH 알고리즘으로 사인해줄수 있음.

ECDH: Elliptic Curve DH
ECDSA: Elliptic Curve Digital Signature Algorithm

DHE or EDH generates a session key per connection in memory.  Even by today’s computing standards it would take thousands of years to break a discrete log problem( http://en.wikipedia.org/wiki/Discrete_logarithm) and you would only see that one session!
