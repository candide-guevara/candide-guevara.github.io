---
layout: diagram
title: Basic notes about cryptography and security
categories : [diagram, cryptography, math]
js_custom: math_notation
diagram_list: [ PKI_Cryptography.svg ]
---

## Cryptography

* One-way function - a function easy to calculate but very complex to determine its inverse f-1(x). 
  Used in Asymmetric cryptography.
* Digital signature - used to authenticate the owner of a document and to ensure its integrity.
  It relies on the encryption of a hash of the document content. The encryption of the hash is a 1 way function.
* Certificate - a document signed by a trusted certification authority (CA) attesting a public key belongs to something/someone
* Random oracle - theoretical model of a black box returning outputting random data for an input it has not seen before. 
  The same input will always return the same output. Cryptographic functions should mimic the behavior of a random oracle as much as possible.
* Stream cypher - an encryption where the key is as long a the message => perfect encryption 
  (invulnerable to statistical attacks) if used only once. A stream key can be output by a random number generator, 
  the seed of the generator is then the decoding/encoding key.


## Birthday theorem 

$$
\mbox{Let F be a pseudo random function so that :}   \\
F:x \to [0..n] \qquad and \qquad (a0..am) \epsilon [0..n]  \\

\mbox{Then probability of } \exists (ai, ak) \epsilon (a0..am) \mbox{ so that } F(ai)=F(ak) : \\
P \simeq \frac{m^{2}}{2n} \qquad if \ m \ll n  \\

\mbox{From this we can deduce the strenght of a k bit lenght hash.} \\
\mbox{To have a 50% chance of at least a collision :} \\
m = 2 ^ {\frac{k}{2}}
$$

## Some definitions

* App security - not dealing with infrastructure security (Firewalls, antivirus...) but with how to make
  Application code invulnerable to attacks (X site scripting, SQL injection ...)
* Threat modeling - determine the attack surface of a system, the possible vectors of attack, the technical and biz impacts
* Hashing functions are too fast => then easiest to brute force, new hashes designed to take more resources

