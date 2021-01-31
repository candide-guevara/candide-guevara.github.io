---
title: Linux, Backing up  BTRFS snapshots to the cloud
date: 2021-01-15
my_extra_options: [ graphviz ]
published: false
categories: [cs_related]
---

## Backup Data model

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box margin="0,0.14"]
  nodesep=0.4
  subgraph cluster_head {
    label="key__volume_uuid\l"
    color=blue
    style=dashed
    seqhead [width="3.2"
      label="SnapshotSeqHead\n(all sequences of snapshots\nassotiated to the same vol)"]
    curseq [width="3.2"
      label="CurrentSequence\n(The seq to which new backups\nwill be appended)"]
    prvseq [shape=box3d width="3.8"
      label="PreviousSequences\n(Old backups still kept in storage)"]
  }
  subgraph cluster_snap {
    label="key__snapshot_uuid"
    color=blue
    style=dashed
    snap [shape=box3d width="4.0"
      label="Snapshot\n(General attributes and parent uuid)"]
  }
  subgraph cluster_chunk {
    label="key__chunks_uuid"
    color=blue
    style=dashed
    chunks [shape=box3d width="3.6"
      label="Chunks\n(start, size, uuid into storage)"]
  }
  seqhead -> {curseq prvseq}
  curseq -> snap
  snap -> chunks
  chunks -> storage
  storage [shape=oval penwidth=2 color=red width="3.2"
    label="Big blog\nstorage system"]
}
```

* How to split the data types based into blobs ?
  * Keep each blob small (a few 100kb) to avoid hitting metadata storage limitations.
  * Separate SnapshotSeqHead from CurrentSequence to minimize blast radius of blob corruption.

### Storage system characteristics

* Minimum requirements for storage systems.
  * Metadata : key-value store
    * Key must be composite
    * Value is an opaque blob for the system
    * Listing by key prefixes should be available
  * Storage : key-value store
    * Key must be composite
    * Value is an opaque blob for the system
    * Cheap to store a lot of data. Ok if retrieves are expensive.

> NOTE: 'S3 glacier' is NOT 'Direct glacier'  
> (cannot use one API to access both products).

* Chosen systems.
  * Metadata : DynamoDB
    * Eternal free tier enough for small data and occasional backups
    * Use tables as key prefix
    * Blob type limited to 400kb
  * Storage : S3 glacier
    * Flexible : can use standard storage class for testing (restore will not take forever)
    * Can list blobs in real time ?
    * Has extra data tier 'deep glacier' compared to direct glacier


## Components

### Metadata

### Storage

### Btrfs shim

### Volume source/destination

[0]: {% post_url linux/0000-00-00-btrfs-for-the-win %}

