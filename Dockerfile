FROM golang:1.22-alpine AS build
WORKDIR /src

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .

# GOARCH is set by Buildx automatically
RUN CGO_ENABLED=0 GOOS=linux \
  go build -trimpath -ldflags="-s -w" \
  -o /out/hvac_ip_mqtt_bridge .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates

WORKDIR /app
COPY --from=build /out/hvac_ip_mqtt_bridge /app/hvac_ip_mqtt_bridge

RUN adduser -D -H -u 10001 appuser
USER 10001

EXPOSE 8080
CMD ["/app/hvac_ip_mqtt_bridge", "--config_file=/config/config.yaml"]

