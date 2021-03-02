---
title: Golang, Some features
date: 2021-01-10
my_extra_options: [ graphviz ]
categories: [cs_related]
---

## The module system

```myviz
digraph {
  node [fontsize=12 fontname=monospace shape=box]
  nodesep=0.3
  ranksep=0.5
  subgraph cluster_module {
    label="Module"
    style=dashed
    gomod [width="2.6"
      label="go.mod file\n(marks the module root)"]
    modpkg [shape=box3d width="2.4"
      label="module packages"]
    note_modpkg [shape=note width="3.2"
      label="Contains libraries/exe/tests\n(only 1 main per package)"]
  }
  subgraph cluster_env {
    label="Environment"
    style=dashed
    gopath [width="2.0"
      label="GOPATH\n(User level)"]
    goroot [width="2.0"
      label="GOROOT\n(System level)"]
    pathsrc [width="1.8"
      label="src/\n(source libs)"]
    pathpkg [width="1.8"
      label="pkg/\n(binary libs)"]
    rootsrc [width="1.8"
      label="src/\n(source libs)"]
    rootpkg [width="1.8"
      label="pkg/\n(binary libs)"]
  }

  gopath -> { pathsrc pathpkg }
  goroot -> { rootsrc rootpkg }
  gomod -> modpkg [style=invis]
  modpkg -> note_modpkg [arrowhead=none color=grey]
}
```

### Examples : run/build/install a file/pkg/module

```sh
alias go="GOENV=/tmp/testenv go"
go env -w GOPATH=/tmp/gopath GOBIN=/tmp/gobin GOCACHE=/tmp/gocache
mkdir -p /tmp/gopath /tmp/gobin /tmp/gocache \
      /tmp/standalone_pkg /tmp/gopath/src/dependent_pkg \
      /tmp/mymodule/ext_dep /tmp/mymodule/another_bin /tmp/mymodule/dependent_pkg

echo '
package main
import "fmt"
func main() { fmt.Println("helloworld") }
' > /tmp/helloworld.go
echo '
package main
import ( "fmt" ; "dependent_pkg" )
func main() { fmt.Println("helloworld", dependent_pkg.Doit()) }
' > /tmp/hello_with_dep.go
echo '
package dependent_pkg
func Doit() string { return "dependent_pkg" }
' > /tmp/some_lib.go

# All these work : `run` builds into a temp file and execs, `build` creates exe in curdir, `install` builds into GOBIN
go run helloworld.go
go build helloworld.go
go install helloworld.go

sed 's/helloworld/standalone_pkg/' /tmp/helloworld.go > /tmp/standalone_pkg/standalone.go
# FAILS since standalone_pkg is looked for in GOPATH
go run standalone_pkg
# OK looks for pkg in curdir
go run ./standalone_pkg
# Needs `-o` otherwise exe name will conflict
go build -o a.out ./standalone_pkg
go install ./standalone_pkg

mv some_lib.go /tmp/gopath/src/dependent_pkg
# Alternatively it works by importing `./dependent_pkg` and `dependent_pkg/some_lib.go` in the curdir.
go run hello_with_dep.go
go build hello_with_dep.go
go install hello_with_dep.go

# Create go module : anywhere within it 'mymodule' refers to the root of all pkg contained within
pushd /tmp/mymodule
go mod init mymodule

# FAIL inside a module you can only dependent on system packages in `GOROOT` or packages in the module itself
# (or binary packages installed in GOPATH/pkg)
go run .
# Be careful it is a trap ! `GOROOT` can only have a single path ?!
#go env -w GOROOT='/usr/lib/go;/tmp/goroot'
sed 's/"dependent_pkg"/"mymodule\/dependent_pkg"/' /tmp/hello_with_dep.go > /tmp/mymodule/hello_with_dep.go
mv /tmp/gopath/src/dependent_pkg /tmp/mymodule
# run/build/install will work as expected (exe name is the module name)
go run .

sed 's/helloworld/another_hello_with_dep/' /tmp/mymodule/hello_with_dep.go > /tmp/mymodule/another_hello_with_dep.go
# FAIL (`main` redefinition) module can only have 1 executable
go run .

mv /tmp/mymodule/another_hello_with_dep.go /tmp/mymodule/another_bin
go run ./another_bin
# NOTE the `...` it will install all exe under the module
go install ./...
# Be careful it is a trap ! `...` (instead of `./...`) will run tests for the whole system ?!
go test ./...

sed 's/"fmt"/( "fmt" ; "golang.org/x/blog/content/cover" )/' /tmp/helloworld.go > /tmp/mymodule/ext_dep/ext_dep.go
# Looks for external dependencies on other modules and installs then into GOPATH/pkg
go mod tidy
# Upgrades all module dependencies to its latest version
go get ./...

unalias go
```


## Interop with c : `cgo`

### Static or dynamic linking

```sh
# Suppose you want the go program to link against mylibs/libthingy.so (or libthingy.a)
go env -w CGO_CFLAGS="-Ithingy_include" \
          CGO_LDFLAGS="-Lmylibs -lthingy.so"
# To link statically use CGO_LDFLAGS="mylibs/libthingy.a"
```

> Does the go program need to be built with the same compiler/linker options as the c library it links with ?


## Channel behavior

{:.my-short-table}
|          | Open & Empty | Open & Full | Closed     | Nil           |
|----------|--------------|-------------|------------|---------------|
| Read     | Blocks | Reads (value, true) | Reads (zero-val, false) | Blocks forever |
| Write    | Ok | Blocks | Panic ! | Blocks forever |
| Close    | Ok (fail for receive-only channel) | Blocks (unless buffered channel) | Panic ! | Panic ! |

