# syntax=docker/dockerfile:1
ARG GO_VERSION=1.26
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS build
ARG TARGETOS
ARG TARGETARCH
ARG MAIN_PACKAGE=.
WORKDIR /src
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -mod=readonly -trimpath -buildvcs=false -ldflags="-s -w" -o /out/app "$MAIN_PACKAGE"

FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /out/app /app
USER 65532:65532
ENTRYPOINT ["/app"]
