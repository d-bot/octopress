---
layout: post
title: "TLS Handshake"
date: 2014-09-21 17:19:41 +0000
comments: true
categories: 
---
TLS Handshake

Client: TCP SYN
Server: TCP SYN+ACK
Client: TCP ACK
———begin TLS———-
           TLS Hello
Server: TLS Hello
           Server Key
Client: TLS Ack
           Server Key check
           Client Key Exchange
Server: TLS Handshake
———-Begin HTTP———
Client: HTTP Request (GET)
Client: HTTP Respond

HTTPS requires four round trips to make a single HTTP request while unencrypted HTTP only requires two


There are two main types of handshakes in TLS: one based on RSA, and one based on Diffie-Hellman. RSA and Diffie-Hellman were the two algorithms which ushered in the era of modern cryptography, and brought cryptography to the masses. These two handshakes differ only in how the two goals of key establishment and authentication are achieved
