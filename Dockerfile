FROM elixir:1.15.7-otp-26-alpine AS ex_builder

ARG customAppPort=8080
ARG customAppHost=localhost

RUN apk update && \
    apk add --no-cache \
    ca-certificates \
    curl \
    gawk \
    git \
    make \
    nodejs \
    npm \
    python3 \
    tar \
    wget \
    g++ \
    && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info

WORKDIR /app
ENV MIX_ENV prod
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH

# Following env var are needed since `runtime.exs` is called on `mix release` command
# See https://hexdocs.pm/elixir/1.16.2/Config.html#module-config-runtime-exs
ENV PORT $customAppPort
ENV HOSTNAME $customAppHost

ADD . .

RUN mix deps.get && \
    mix compile && \
    mix release && \
    cd assets && \
    npm install && \
    npm install node-gyp && \
    npm install bcrypt && \
    npm run lint && \
    npm run release && \
    cd .. && \
    mix openapi.stepflow && \
    mix openapi.backend && \
    mix phx.digest

FROM alpine:3.19.1

WORKDIR /app

ARG customAppPort=8080

ENV PORT $customAppPort

RUN apk update && \
    apk add bash openssl curl libstdc++

COPY --from=ex_builder /app/_build/prod/rel/ex_backend .
COPY --from=ex_builder /app/priv/static static/

RUN apk add --no-cache tzdata

RUN backend="$(ls -1 lib/ | grep ex_backend)" && \
    rm -rf lib/$backend/priv/static/ && \
    mv static/ lib/$backend/priv/

HEALTHCHECK --interval=30s --start-period=2s --retries=2 --timeout=3s CMD curl -v --silent --fail http://localhost:$PORT/ || exit 1

CMD ["./bin/ex_backend", "start"]
