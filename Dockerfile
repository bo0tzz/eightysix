FROM bitwalker/alpine-elixir:latest AS build

ENV MIX_ENV=prod

WORKDIR /build/

COPY . .
RUN mix release

FROM bitwalker/alpine-elixir:latest AS run

COPY --from=build /build/_build/prod/rel/eightysix/ ./
USER default
CMD ./bin/eightysix foreground

