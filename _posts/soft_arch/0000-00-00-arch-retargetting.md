---
title: Distributed systems, Retargetting adds architecture
date: 2015-07-07
categories: [cs_related, distributed, architecture]
---

## Glossary
* Creative - add/banner shape and appearance
* Publisher - web site that includes adds
* Advertiser - retailer that pays (indirectly) publishers to display adds
* ROI - return on investment
* CPM - cost per a thousand impressions
* CPC - cost per click pricing model where **only** customers clicks on ads are Monetized
* RTB - real time bidding
* Behaviour retargeting - display adds on customers that previously visited the advertiser retail site (more receptive, chance of conversion)
* Personalized retargeting - like behaviour retarget but customizes adds to display the previously browsed items
* Email retargeting - like perso retarget but uses email instead of banner adds
* Search retargeting - display adds based on user search queries related to the advertiser business. Unlike previous techniques aims at bringing new traffic to the adversite site

## Architecture

From the excellent talks given by Criteo at Devoxx ([here][1] and [here][2]) I sketched a high level diagram of what their systems might look like.

![Arch_Criteo_Retargetting.svg]({{ site.images }}/Arch_Criteo_Retargetting.svg){:.my-wide-img}

[1]: http://labs.criteo.com/2014/05/criteo-rd-devoxxfr/
[2]: https://www.parleys.com/tutorial/anatomie-de-linfrastructure-de-prediction-criteo-machine-learning-log-management-hadoop
