APPLICATION := dummy
BUILD_DIR := bin

NOROOT=-u $$(id -u):$$(id -g)
SRCDIR=/go/src/github.com/agalitsyn/bashstyle
DOCKERFLAGS=--rm=true $(NOROOT) -v $(CURDIR):$(SRCDIR) -w $(SRCDIR)
BUILDIMAGE=golang:1.7

.PHONY: all
all:
	docker run $(DOCKERFLAGS) $(BUILDIMAGE) make clean $(BUILD_DIR)/$(APPLICATION)

.PHONY: run
run:
	goreman start

$(BUILD_DIR)/$(APPLICATION): *.go
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -a -installsuffix cgo -o $@ .

.PHONY: clean
clean:
	rm -rf bin

.PHONY: install-tools
install-tools:
	go get -u github.com/mattn/goreman
