---
title: Tools, Git version tree and useful commands
date: 2015-12-01
categories: [cs_related]
---

## Glossary
* Blobs =  The way git stores files. Can be retrieved by its unique hash
* Tree = The way git stores directories. Can be retrived by its unique hash
* Index = Staging = Cache = temporary storage holding the trees and blobs to commit
* Ref-log = local (no shared with upstream) log of 
* Plumbing/Porcelain commands = internal/user facing commands

## Commit/Tree-ish
* Commit-ish : every expression that can be resolved into a node in the version tree
* Tree-ish : a commit-ish followed by a path. A commit-ish **is a** tree-ish to the root
* @ operator **only** works with the ref-log

              D       F  <-- master <-- HEAD
               \     / \
                \   /   |
                 \ /    |
       topic -->  B     C
                   \   /
                    \ /
                     A

{:.my-table}
| Commit-ish | [Resolves to][2] |
|------------|-------------|
| `HEAD`       | `F` (the branch HEAD is currently pointing to) |
| `HEAD^ = HEAD^1 = HEAD~ = HEAD~1` | `B` (HEAD's first parent) |
| `F^2` | `C` (F's second parent) |
| `D~~ = D~2 = D^^` | `A` (2 past generation **first** ancestor) |
| `refs/head/master = head/master = master` | `F` (master branch tip) |
| `HEAD@{1 days ago}` | `B` (yesterday you were working on the topic branch) |
| `:/commit\_msg` | The **youngest matching command from ANY ref** commit matching message |

## Revision ranges

            A---B---C topic
           /
      D---E---F---G master

{:.my-table}
| Revision range | Resolves to |
|----------------|-------------|
| `B` | `D, E, A, B` (all commits reachable from B) |
| `B^@` | `D, E, A` (all commits reachable from B, **except himself**) |
| `C G` | `ALL` (commits reachable from **both** C and G) |
| `G ^C = C..G` (double dot) | `G, F` (commits reachable by G **and NOT** by C) |
| `C...G` (triple dot) | `C, B, A, F, G` (commits reachable by C or G but **NOT both**) |

## Reset and checkout

          A---B---C topic                                     A---B---C topic <- HEAD                          A---B---C topic
         /                        (git checkout topic)       /                         (git checkout F)       / 
    D---E---F---G master <- HEAD                        D---E---F---G master                             D---E---F---G master
                                                                                                                 ^
                                                                                                               HEAD (detached mode)


          A---B---C topic                                     A---B---C topic <- master <- HEAD 
         /                        (git reset topic)          /                        
    D---E---F---G master <- HEAD                        D---E---F---G <- Orphan branch (may be cleaned on garbage collection)

{:.my-table}
| Reset/Checkout command | Branch ref | Index | Working directory |
|------------------------|------------|-------|-------------------|
| `git reset --soft <commit-ish>` | \<commit-ish\> | NO change | NO change |
| `git reset --mixed <commit-ish>` | \<commit-ish\> | \<commit-ish\> | NO change |
| `git reset --hard <commit-ish>` | \<commit-ish\> | \<commit-ish\> | \<commit-ish\> |
| `git reset --mixed <path>` (cannot accept a commit-ish) | N/A | \<commit-ish\> | NO change |
| `git reset --hard <path>` (cannot accept a commit-ish) | N/A | \<commit-ish\> | \<commit-ish\> |
| `git checkout <commit-ish>` (like reset hard [with exceptions][1]) | \<commit-ish\> | \<commit-ish\> | \<commit-ish\> |
| `git checkout <commit-ish> <path>` | NO change | NO change (unless path is staged) | reverts \<path\> to \<commit-ish\> | 

## [.git directory][3]
* .git/refs : contains the commit hashes for the different local/upstream branches and tags
* .git/objects : stores blobs, trees and [packs][4] in a content addressable filesystem (the object hash = path)
* .git/logs : contains the ref-log for the different branches
* .git/HEAD : a simple file with the name of the ref HEAD currently points to (eg: refs/heads/master)

## Rebasing branches

            F---G topic <- HEAD                                    D---E branch
           /                                                      / 
          D---E branch                (git rebase master)        /   D'---F'---G' topic <- HEAD
         /                                                      /   / 
    A---B---C master                                       A---B---C master


                F---G topic <- HEAD                                                    D---E branch
               /                                                                      / 
          D---E branch                (git rebase --onto master branch topic)        /   F'---G' topic <- HEAD
         /                                                                          /   / 
    A---B---C master                                                           A---B---C master


    F---G alien                                                                A'---B'---C' branch <- HEAD
                                      (git rebase --root --onto alien)        /              
          D---E branch                               or                  F---G alien
         /                                   (git rebase alien)                     
    A---B---C master <- HEAD                                             A---B---D---E branch

* Notice the rebased commits are brand new, they all have a **different hash**

## Interesting commands
* `stash pop|list` : stores the contents of the working directory away and `reset --hard`. You can restore using `stash pop`
* `show -p <revision-range>` : outputs a patch file with the changes in all commits in \<revision-range\>
* `cherry-pick <revision-range>` : applies all changes in \<revision-range\> on top of HEAD. It creates **new commits not linked to the range**
* `merge --strategy=recursive -Xours <branch>` : merges with \<branch\>, attempts to solve merge to the same files, but **defaults** to HEAD's branch in case of conflicts
* `log --branches --before=2015-12-25 --after=2015-11-26` : displays all commits between the 2 dates for ALL branches

## .git/config and remotes

![Git_Upstream.svg]({{ site.images }}/Git_Upstream.svg){:.my-block-wide-img}

[1]: http://www.git-scm.com/book/en/v2/Git-Tools-Reset-Demystified#Check-It-Out
[2]: http://git-scm.com/docs/gitrevisions
[3]: http://git-scm.com/docs/gitrepository-layout
[4]: http://git-scm.com/book/en/v2/Git-Internals-Packfiles
