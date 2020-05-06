---
title: Language, Modèle simplifié de la grammaire française
date: 2020-04-20
published: false
my_extra_options: [ graphviz ]
categories: [ misc ]
---

Bien entendu, la classification n'est ni exhaustive ni correcte.
Le but est plutôt d'arriver à un system simple qui me permette de structurer ma connaissance de la langue.
Et, par extension de contraster le français avec [d'autres languages][0].

```myviz
digraph {
  grammaire [root=true shape=octagon penwidth=3]

  parties_discours [color=blue penwidth=2]
  pd_variable [color=blue
    label="variable
genre et nombre"
  ]
  pd_invariable [color=blue
    label="invariable
genre et nombre"
  ]
  pd_variable_classes [color=blue shape=record 
    label="{substantif | adjectif | ...}"
  ]
  pd_invariable_classes [color=blue shape=record 
    label="{preposition | adverbe | ...}"
  ]

  syntaxe [color=red penwidth=2]
  complement_objet [color=red
    label=<complement<br/>d'object>
  ]
  complement_circonstantiel [color=red
    label=<complement<br/>circonstantiel>
  ]
  sujet [color=red shape=record]
  co_classes [color=red shape=record]
  ci_classes [color=red shape=record]

  verbe [color=green penwidth=2]
  verbe [color=green]
  mode [shape=note color=green]
  temps [shape=note color=green]
  reflexivite [shape=note color=green]
  transitivite [shape=note color=green]
  active_passive [shape=note color=green
    label="voix
active/passive"
  ]
  mode_simple [color=green]
  mode_avec_aux [color=green]
  ms_classes [color=green shape=record]
  ma_classes [color=green shape=record]


  grammaire -> parties_discours
  parties_discours -> {pd_variable pd_invariable}
  pd_variable -> {pd_variable_classes}
  pd_invariable -> {pd_invariable_classes}

  grammaire -> syntaxe
  syntaxe -> {sujet complement_objet complement_circonstantiel}
  complement_objet -> {co_classes}
  complement_circonstantiel -> {ci_classes}

  # Because of layout BS we need to invert the edges for the verb branch
  verbe -> grammaire [dir=back]
  {mode temps reflexivite transitivite active_passive} -> verbe [dir=back]
  {mode_simple mode_avec_aux} -> mode [dir=back]
  ms_classes -> mode_simple [dir=back]
  ma_classes -> mode_avec_aux [dir=back]
  {rank=source ms_classes ma_classes}

  #complement_objet -> transitivite
  #pd_variable_classes -> verbe [label="substantivation"]
}
```

## Parties du discours

Les [parties du discours][1] sont les catégories grammaticales assotiées aux (groupes de) mots __indépendamment de leur contexte dans une phrase__ (contrairement à la syntaxe).

> Remarque : cette définition n'est pas parfaite quand on pense aux pronoms, conjonctions ...

### Définitions

* Personne grammaticale : relation entre un (groupe) mot et celui qui parle. Cette relation associe le (groupe) mot au locuteur(s), interlocuteur(s) ou aucun des précédents.

### Parties du discours variables (genre/nombre)

* Nom/substantif : sert à exprimer __l'existance__ d'une chose/concept ...
* Adjectif : sert à donner un __attribut__ à un substantif. Cet attribut peut être une __qualité__ ou une façon de __distinguer__ un substantif parmis des semblables.
  * Déterminant : chaque classe de déterminant permet de distinguer un substantif dans un espace particulier (possession, position ...)
    * Article défini/indéfini
    * Article partitif : exprime que le nom qualifié est une __partie__ d'un tout.
    > Je bois __du__ vin. Je mange __de la__ viande.
    * Adjectif posséssif (il s'accorde aussi avec la personne grammaticale)
    > __Ma__ moto et __ma__ voiture sont __mes__ possessions les plus précieuses.
    * Adjectif démonstratif
    > __Cette__ piquette boche me dégoûte.
    * Adjectif intérrogatif : exprime une question par rapport à l'identité du substantif.
    > Quel jambon cru tu préfères ?
  * Adjectif qualificatif
    * Adjectif relationel : se distingue du qualificatif uniquement par ses règles d'usage (l'idée de relation __n'est pas un discriminant__ fiable).
    > La moto __noir__ émet un vrombissement __symphonique__. (noir=qualificatif, symphonique=relatif)
* Pronom : remplace un substantif. Peut représenter quelque chose précedemment enoncée dans le discours, ou implicite ('je' renvoie à la personne qui parle), ou un concept ('tous', 'nul').
  * Personnel : représente la personne grammaticale
  * Déterminant : parallèle direct avec les adjectifs déterminants.
  > __Laquelle__ tu voudrais conduire ? Je voudrais essayer __celle-là__. Je te prête __la mienne__ donc.
  > On trouve beaucoup de Kandinskis à la pinacothèque de Munich => On y trouve beaucoup de Kandinskis (complément de lieu)
  * Pronom relatif : introduit une proposition subordonnée dans laquelle il peut jouer plusieurs roles syntaxiques (sujet, COD ...). Dit 'relatif'car il introduit une relation (sujet, COD ...) entre son référent et la proposition subordonnée.
    * Pronom relatif composé : il est accompagné par une préposition. Seule catégorie de pronom relatifs qui s'accorde en genre/nombre
    > Mon ancienne moto __avec laquelle__ j'ai longtemps voyagé, était une suzuki.

### Parties du discours INvariables (genre/nombre)

* Pronom : cette catégorie est à cheval entre variable et invariable.
  * Pronom relatif :
    > Les terres du pays où je suis né sont fertiles. ('où' remplace 'pays' en tant que complément de lieu dans la subordonnée)
    * Pronom relatif déclinable : sous catégorie des pronom relatifs dont les membres se déclinent selon le cas du référent dans la subordonnée.
    > Le canard __qui nage dans la mare__ semble appétissant. ('qui' remplace 'le canard' en tant que sujet dans la subordonnée)  
    > Le canard __que j'ai mangé ce soir__ était excellent. ('que' remplace 'le canard' en tant que COD dans la subordonnée)
  * Pronom adverbial : piège, aucune relation avec un adverbe. Ce pronom remplace entièrement divers type de compléments (d'objet, circonstantiels ...)
  > J'ai acheté du fromage de chèvre => J'en ai acheté (remplace COD)  
  > On trouve beaucoup de Kandinskis à la pinacothèque de Munich => On y trouve beaucoup de Kandinskis (complément de lieu)
* Adverbe
* Préposistion
* Conjonction
  * Conjonction de coordination
  * Conjonction de subordination

### Des mots ayant différentes catégories selon leur forme

Certains méchanismes permettent à un même mot d'avoir __diverse formes__ appartenant à des parties du discours différentes.

* quel méchanisme pour décliner transgresser -> trangression ?
* quel méchanisme pour décliner présider -> président -> présidentiel ?

### Une même forme, plusieures catégories

* de
* celui

### Exemples complexes

* plupart/beaucoup


## Syntaxe

La syntaxe est partie de la grammaire qui étudie les relations entre les mots constituant une proposition/phrase, les règles qui donnent un sens à chaque partie.

### Définitions

* Fléxion : changement de forme à la fin d'un mot pour l'accorder en genre/nombre/cas/temps.
* Déclinaison/Accord : fléxion des mots autre que les verbes.
  * Conjugaison : fléxion des verbes.
  * Désinence : éléments ajouté à la racide du mot lors de sa flexion.
* Cas : fonction d'un groupe nominal au sein d'une proposition.
  * Exemples : sujet, complément d'object ...

### Fonctions de l'adjectif

* épithète
* attribut

## Verbe : liens entre forme et sens

* mode
* temps

### Transistive / intransistive / reflexive

* Transitive : the verb acts on something, most common case.
    * el perro muerde el juguete
* Intrasitive : the verb does not have an object
    * el perro regresó a la casa
* Reflexive : the subject and object are the same
    * el perro se sienta


[0]: {% post_url lang_human/0000-00-00-german-grammar-primer %}
[1]: https://www.cnrtl.fr/definition/discours/1
