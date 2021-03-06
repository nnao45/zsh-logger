
GO15VENDOREXPERIMENT=1

NAME	 := zsh-logger
TARGET	 := bin/$(NAME)
VERSION  := v1.0.6
DIST_DIRS := find * -type d -exec

SRCS	:= $(shell find . -type f -name '*.go')
LDFLAGS := -ldflags="-s -w -X \"main.version=$(VERSION)\" -extldflags \"-static\""

$(TARGET): $(SRCS)
	go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(NAME)

.PHONY: install clean cross-build upde dep dep-install dist

install:
	go install $(LDFLAGS)

clean:
	rm -rf bin/*
	rm -rf vendor/*
	rm -rf dist/*

upde:
	dep ensure -update

deps:
	dep ensure

dep-install:
	go get github.com/golang/dep/cmd/dep

cross-build: deps
	for os in darwin linux windows; do \
		for arch in amd64 386; do \
			GOOS=$$os GOARCH=$$arch CGO_ENABLED=0 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o dist/$(NAME)-$$os-$$arch/$(NAME); \
		done; \
	done

dist:
	cd dist && \
		$(DIST_DIRS) cp ../LICENSE {} \; && \
		$(DIST_DIRS) cp ../README.md {} \; && \
		$(DIST_DIRS) cp ../logger.sh {} \; && \
		$(DIST_DIRS) tar -zcf {}-$(VERSION).tar.gz {} \; && \
		$(DIST_DIRS) zip -r {}-$(VERSION).zip {} \; && \
		cd ..