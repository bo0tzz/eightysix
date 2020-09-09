FROM rust as builder
WORKDIR /usr/src/

# Hack to cache the dependencies
RUN USER=root cargo new --bin eightysix
WORKDIR /usr/src/eightysix
COPY Cargo.* ./
RUN cargo build --release
RUN rm src/*.rs
RUN rm target/release/eightysix

COPY . .
RUN cargo build --release

FROM alpine
COPY --from=builder /usr/src/eightysix/target/release/eightysix /usr/local/bin/eightysix
CMD ["eightysix"]
