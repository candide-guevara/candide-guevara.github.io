---
title: Web security cross domain
date: 2015-06-01
categories: [cs_related, web]
---

### Cross domain calls
* XHR - xml http request (javascript object used for ajax calls)
* XSS - cross site scripting (embedding malicious scripts in trusted web pages)
* CORS - cross domain resource sharing : a mechanism based on new http headers in rq and rs to be able to perform cross site ajax calls.
  Minor security advantage over non controlled calls. It does **not prevent untrusted scripts on the browser sending data to untrusted servers**
  implementing CORS. Depending on the type of request (method, headers) a preflight rq using the OPTIONS method may be sent to query the server for permission.
* Same origin policy - normally ajax calls to other domains than the one where the document was retrieved from are not allowed.
  Domain and port must tbe the same. CORS and JSONP are a mechanism to bypass it since script loading is not affected by same origin policy.

![Web_Cross_Domain_Call.svg]({{ site.images }}/Web_Cross_Domain_Call.svg){:.my-block-wide-img}
