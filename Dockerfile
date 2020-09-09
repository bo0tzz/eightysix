FROM clux/muslrust as builder
WORKDIR /usr/src/

# Hack to cache the dependencies
RUN USER=root cargo new --bin eightysix
WORKDIR /usr/src/eightysix
COPY Cargo.* ./
RUN cargo build --release
RUN rm src/*.rs
RUN rm target/x86_64-unknown-linux-musl/release/eightysix

ENV RUST_BACKTRACE=full
COPY . .
RUN cargo build --release

FROM scratch
COPY --from=builder /usr/src/eightysix/target/x86_64-unknown-linux-musl/release/eightysix .
ENV RUST_BACKTRACE=full
CMD ["./eightysix"]
