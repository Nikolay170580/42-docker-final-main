FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o tracker .

FROM alpine:latest

RUN apk --no-cache add ca-certificates sqlite

WORKDIR /root/

COPY --from=builder /app/tracker .

CMD ["sh", "-c", "sqlite3 tracker.db \"CREATE TABLE IF NOT EXISTS parcel (number INTEGER PRIMARY KEY AUTOINCREMENT, client INTEGER NOT NULL, status TEXT NOT NULL, address TEXT NOT NULL, created_at TEXT NOT NULL);\" && exec ./tracker"]