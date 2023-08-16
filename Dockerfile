FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata
COPY listmonk .
COPY static static
COPY custom-templates custom-templates
COPY config.toml.sample config.toml
COPY config-demo.toml .
CMD ["./listmonk", "--static-dir=custom-templates"]
EXPOSE 9000
