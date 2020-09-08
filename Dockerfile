FROM rust as builder
WORKDIR /usr/src/eightysix
COPY . .
RUN cargo install --path

FROM alpine
COPY --from=builder /usr/local/cargo/bin/eightysix /usr/local/bin/eightysix
CMD ["eightysix"]