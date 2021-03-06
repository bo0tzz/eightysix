FROM bitwalker/alpine-elixir:latest AS build

ENV MIX_ENV=prod

WORKDIR /build/

COPY . .
RUN mix deps.get
RUN mix release

FROM bitwalker/alpine-elixir:latest AS run

RUN apk add tzdata
ENV TZ Europe/Amsterdam

COPY --from=build /build/_build/prod/rel/eightysix/ ./
RUN chmod +x ./bin/eightysix
CMD ./bin/eightysix start

