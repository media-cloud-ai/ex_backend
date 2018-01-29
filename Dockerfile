FROM elixir:1.6.0-alpine AS builder

RUN apk update
RUN apk add gawk git make curl python

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get
RUN mix release.init
RUN mix release --env=$MIX_ENV
RUN mix phx.digest

FROM alpine:3.6

WORKDIR /app

RUN apk update
RUN apk add bash openssl

COPY --from=builder /app/_build/prod/rel/ex_subtil_backend .

CMD ["./bin/ex_subtil_backend", "foreground"]
