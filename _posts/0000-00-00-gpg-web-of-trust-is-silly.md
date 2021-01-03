---
title: GPG, web of trust is useless
date: 2020-12-12
categories: [quick_notes]
---

When I update my system with `pacman` I am sometimes asked to accept new keys into pacman's keyring.
I thought it would be possible using `gpg` to inspect the [web of trust][0] to have a feeling whether I can trust the key.

> __TL;DR__ You cannot use gpg to crawl the web of trust.   
It is useless for a random person to verify a signature of an unknown entity.

### Use gpg's `--homedir` option to avoid adding garbage to your keyring

Example : `gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --recv-keys 0x9741E8AC`

## Key digests are too collision prone

As example keys we use [arch linux master keys][1]. Pierre Schmitz key digest is `0x9741E8AC` looking at the keyserver there are 2 keys matching : [random wanker][2] and [the key I want][3].
Running `gpg --keyserver keyserver.ubuntu.com --recv-keys 0x9741E8AC` will silently fail since it attempts to get the key from "random wanker".

**Be careful it is a trap !**  
`gpg --search-keys 0x9741E8AC` will only show "random wanker" key...

## `gpg` cannot derive trust from signing keys

[Pierre Schmitz key][3] in the the keyserver webpage shows the signatures from other people (in a sort of cryptic and unhelpful way).
`gpg` is unable to give this information.

```sh
master_key="0E8B644079F599DFC1DDC3973348882F6AC6A4C2"
signing_key="4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC"
gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --recv-keys "$master_key" "$signing_key"
# This will ONLY show self signatures for the key.
gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --list-sigs

# You need to manually mark the keys you trust with `trust 5`
gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --edit-key "$signing_key"

# No f*cking idea what this is for
gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --update-trustdb 
gpg --homedir /tmp/gpg_test --keyserver keyserver.ubuntu.com --list-keys
```

In the example above, `master_key` has been signed by `signing_key` and we explicitely said we trust `signing_key`.  
You would expect trust to be propagated to `master_key`. However `--list-keys` will only show `signing_key` as trusted...

* Do you really have to manually go over all of your keys and set their trust level ?
  * Is there no way to crawl the existing web of trust to get this info somehow ?

> NOTE: your `trustdb` file is private, which is good otherwise people can know which keys you trust.

### CONCLUSION : what a piece of cr\*p !

[0]:https://en.wikipedia.org/wiki/Web_of_trust
[1]:https://archlinux.org/master-keys/
[2]:https://keyserver.ubuntu.com/pks/lookup?search=0x9741E8AC&fingerprint=on&op=index
[3]:https://keyserver.ubuntu.com/pks/lookup?op=vindex&fingerprint=on&exact=on&search=0x4AA4767BBC9C4B1D18AE28B77F2D434B9741E8AC

