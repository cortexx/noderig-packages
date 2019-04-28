# Noderig packages

This code repository contains __Noderig__ packaging scripts.  
For more details about Noderig see the [main repository](https://github.com/ovh/noderig) on github.

## Requirements

Package name | Release number | Resources
-------------|----------------|---------------------
Git          | >= 2.X.X       | [Git Documentation](https://git-scm.com/doc)
Make         | >= 3.8X        | [Make Documentation](https://www.gnu.org/doc/doc.html)
Golang       | >= 1.11        | [Golang Documentation](https://golang.org/doc/)
Glide        | >= 0.10.X      | [Glide Documentation](https://glide.readthedocs.io/en/latest/)
FPM          | >= 0.10.X      | [FPM Documentation](https://fpm.readthedocs.io/en/latest/intro.html)

## Print Makefile usage

```bash
make help
```

## Get Noderig's repository available tags

```bash
make list-releases # get all available tags
make get-last-release # get the latest tag
```

## How to build a package

If no `RELEASE_NUMBER` is given to the `build` target, the latest available tag on the [Noderig repository](https://github.com/ovh/noderig) is automatically used.

### How to build a .deb package

Usage:

```bash
make build VERSION="${RELEASE_NUMBER}"
make deb
```

### How to build a .rpm package

Usage:

```bash
make build VERSION=${RELEASE_NUMBER}
make rpm
```

## Troubleshooting

### How to debug Glide installation

If you encounter the following error:

```text
glide not found. Did you add $GOBIN to your $PATH?
Fail to install glide
```

Add the following declarations in your Bash profile:

```bash
export GOPATH="$HOME/go/"
export PATH=$HOME/go/bin:$PATH
```

### How to debug package building

If you encounter the following error:

```bash
/bin/sh: fpm: command not found
make: *** [deb] Error 127
```

Read this [documentation](https://fpm.readthedocs.io/en/latest/intro.html) and follow detailed instructions to install `FPM` tool.  
On MacOS X system like, you will maybe need to set `GEM_HOME` and `PATH` environment variables.