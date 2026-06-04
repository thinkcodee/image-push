# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Install git for go modules
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o image-push cmd/tool/main.go

# Runtime stage
FROM alpine:3.19

RUN apk add --no-cache ca-certificates

WORKDIR /app
# Copy binary from builder
COPY --from=builder /build/image-push .

# Make it executable
RUN chmod +x image-push

ENTRYPOINT ["./image-push"]
