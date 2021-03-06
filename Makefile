GOTOOLS = \
	github.com/alecthomas/gometalinter \
	golang.org/x/tools/cmd/cover \
	github.com/golang/dep/cmd/dep \

GOPACKAGES := $(go list ./... | grep -v /vendor/)
VERSION ?= $(shell git describe --abbrev=0 --tags)
CHANGELOG_VERSION = $(shell perl -ne '/^\#\# (\d+(\.\d+)+) / && print "$$1\n"' CHANGELOG.md | head -n1)

.PHONY: setup
setup: ## Install all the build and lint dependencies
	go get -u $(GOTOOLS)
	gometalinter --install

.PHONY: dep
dep: ## Run dep ensure and prune
	dep ensure

.PHONY: test
test: ## Run all the tests
	echo 'mode: atomic' > coverage.txt && go test -covermode=atomic -coverprofile=coverage.txt -v -timeout=30s $(GOPACKAGES)

.PHONY: integration
integration: ## Run integration tests
	go test -v -tags=integration ./integration/...

.PHONY: cover
cover: test ## Run all the tests and opens the coverage report
	go tool cover -html=coverage.txt

.PHONY: fmt
fmt: ## goimports all go files
	find . -name '*.go' -not -wholename './vendor/*' | while read -r file; do gofmt -s -w "$$file"; goimports -w "$$file"; done

.PHONY: lint
lint: ## Run all the linters
	gometalinter

.PHONY: ci
ci: lint ## Run all code checks and tests with coverage reporting
	./scripts/cover

.PHONY: build
build: ## Build a version
	CGO_ENABLED=0 go build $(GOPACKAGES)

.PHONY: clean
clean: ## Remove temporary files
	go clean

.PHONY: verify
verify: ## Verify the version is referenced in the CHANGELOG
	@if [ "$(VERSION)" = "$(CHANGELOG_VERSION)" ]; then \
		echo "version: $(VERSION)"; \
	else \
		echo "Version number not found in CHANGELOG.md"; \
		echo "version: $(VERSION)"; \
		echo "CHANGELOG: $(CHANGELOG_VERSION)"; \
		exit 1; \
	fi

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := build
