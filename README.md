# Codeship API (v2) Client for Go

[![Codeship Status for codeship/codeship-go](https://app.codeship.com/projects/c38f3280-792b-0135-21bb-4e0cf8ff365b/status?branch=master)](https://app.codeship.com/projects/244943)

## Usage

`go get -u github.com/codeship/codeship-go`

This library is intended to make integrating with Codeship fairly simple.

To start, you need to import the package:

```go
package main

import (
    codeship "github.com/codeship/codeship-go"
)
```

This library exposes the package `codeship`.

Getting a new API Client from it is done by calling `codeship.New()`:

```go
client, err := codeship.New("username", "password")
```

You must then scope the client to a single Organization that you have access to:

```go
org, err := client.Scope(ctx, "codeship")
```

You can then perform calls to the API on behalf of an Organization:

```go
projects, err := org.ListProjects(ctx)
```

## Authentication

Authentication is handled automatically via the API Client using the provided `username` and `password`.

If you would like to manually re-authenticate, you may do this by calling the `Authenticate` method on the `client`:

```go
err := client.Authenticate(ctx)
```

## Response

All API methods also return a `codeship.Response` type that contains the actual `*http.Response` embedded as well as a `Links` type that contains information to be used for pagination.

## Pagination

Pagination is provided for all requests that can return multiple results. The methods that are able to be paginated all take a variable argument of type `PaginationOption` such as: `ListProjects(opts ...PaginationOption)`.

We have defined two helper functions, `Page` and `PerPage`, to make pagination easier.

Usage is as follows:

```go
// defaults to first page with page_size of 30
projects, resp, err := org.ListProjects()

// paging forwards with 50 results per page
for {
    if resp.IsLastPage() || resp.Next == "" {
        break
    }

    next, _ := resp.NextPage()

    projects, resp, _ = org.ListProjects(codeship.Page(next), codeship.PerPage(50))
}

// paging backwards with 50 results per page
for {
    if current, _ := resp.CurrentPage(); current == 1 || resp.Previous == "" {
        break
    }

    prev, _ := resp.PreviousPage()

    projects, resp, _ = org.ListProjects(codeship.Page(prev), codeship.PerPage(50))
}
```

## Logging

You can enable verbose logging of all HTTP requests/responses by configuring the `client` via the functional option `Verbose(verbose bool)` when instantiating the client:

```go
client, err := codeship.New("username", "password", codeship.Verbose(true))
```

The default logger logs to STDOUT but can be replaced by any instance of `*log.Logger`:

```go
var (
    buf    bytes.Buffer
    logger = log.New(&buf, "INFO: ", log.Lshortfile)
)

client, err := codeship.New("username", "password", codeship.Verbose(true), codeship.Logger(logger))
```

## Documentation

TODO: link to GoDoc

## Contributing

This project follows Codeship's [Go best practices](https://github.com/codeship/go-best-practices). Please review them and make sure your PR follows the guidelines laid out before submitting.

### Setup

This project uses [dep](https://github.com/golang/dep) for dependency management.

To install/update dep and all dependencies, run:

```bash
make setup
```

### Testing

```bash
make test
```

We aim for > 80% test coverage. You can view the current coverage info by running:

```bash
make cover
```

### Linting

```bash
make lint
```

### Other

```bash
$ make help

setup                          Install all the build and lint dependencies
dep                            Run dep ensure and prune
test                           Run all the tests
cover                          Run all the tests and opens the coverage report
fmt                            goimports all go files
lint                           Run all the linters
ci                             Run all the tests and code checks
build                          Build a version
clean                          Remove temporary files
```