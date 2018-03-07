FROM elixir:1.6.0-alpine AS ex_builder

RUN apk update && \
    apk add --no-cache \
    ca-certificates \
    curl \
    gawk \
    git \
    make \
    nodejs \
    python \
    tar \
    wget \
    && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info && \
    cd /usr/local/bin && \
    wget https://yarnpkg.com/latest.tar.gz && \
    tar zvxf latest.tar.gz && \
    ln -s /usr/local/bin/dist/bin/yarn.js /usr/local/bin/yarn.js

WORKDIR /app
ENV MIX_ENV prod
ADD . .
RUN mix deps.get && \
    mix release.init && \
    mix release --env=$MIX_ENV && \
    cd assets && \
    /usr/local/bin/yarn && \
    /usr/local/bin/yarn run release && \
    cd .. && \
    mix phx.digest

FROM alpine:3.6

WORKDIR /app

RUN apk update && \
    apk add bash openssl

COPY --from=ex_builder /app/_build/prod/rel/ex_subtil_backend .
COPY --from=ex_builder /app/priv/static lib/ex_subtil_backend-0.0.1/priv/static/

CMD ["./bin/ex_subtil_backend", "foreground"]
