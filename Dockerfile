FROM clux/muslrust as builder
WORKDIR /usr/src/

# Hack to cache the dependencies
RUN USER=root cargo new --bin eightysix
WORKDIR /usr/src/eightysix
COPY Cargo.* ./
RUN cargo build --release
RUN rm src/*.rs

RUN rm target/x86_64-unknown-linux-musl/release/eightysix
RUN rm target/x86_64-unknown-linux-musl/release/eightysix.d
RUN rm -r target/x86_64-unknown-linux-musl/release/incremental
RUN rm -r target/x86_64-unknown-linux-musl/release/.fingerprint/eightysix*

ENV RUST_BACKTRACE=full
COPY . .
RUN cargo build --release

FROM scratch
COPY --from=builder /usr/src/eightysix/target/x86_64-unknown-linux-musl/release/eightysix .
COPY --from=builder /etc/ssl/certs ./certs
ENV SSL_CERT_FILE=/certs/ca-certificates.crt
ENV SSL_CERT_DIR=/certs
ENV RUST_BACKTRACE=full
CMD ["./eightysix"]
