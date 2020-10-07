FROM golang:latest AS builder

RUN go get -d -u github.com/golang/dep && \
    cd $(go env GOPATH)/src/github.com/golang/dep && \
    DEP_LATEST=$(git describe --abbrev=0 --tags) && \
    git checkout $DEP_LATEST && \
    go install -ldflags="-X main.version=$DEP_LATEST" ./cmd/dep && \
    git checkout master

RUN mkdir -p $(go env GOPATH)/src/github.com/influxdata && \
    git clone https://github.com/svenklemm/telegraf.git -b postgres $(go env GOPATH)/src/github.com/influxdata/telegraf && \
    cd $(go env GOPATH)/src/github.com/influxdata/telegraf && \
    make && \
    make install


FROM ubuntu:latest

COPY --from=builder /usr/local/bin/telegraf /usr/local/bin/telegraf

ENTRYPOINT ["/usr/local/bin/telegraf"]
