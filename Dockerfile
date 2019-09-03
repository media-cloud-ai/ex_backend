FROM elixir:1.8.1-alpine AS ex_builder

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
    g++ \
    && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix hex.info && \
    cd /usr/local/bin && \
    curl -o- -L https://yarnpkg.com/install.sh | sh -s -- --version 1.9.4

WORKDIR /app
ENV MIX_ENV prod
ENV PATH /root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH
ADD . .

RUN mix deps.get && \
    mix compile && \
    mix distillery.release --env=$MIX_ENV && \
    mix generate_documentation && \
    cd assets && \
    yarn install --network-timeout 1000000 && \
    yarn add --force node-sass && \
    yarn add node-gyp && \
    yarn add bcrypt && \
    yarn run lint && \
    yarn run release && \
    cd .. && \
    mix phx.digest

FROM alpine:3.9

WORKDIR /app

RUN apk update && \
    apk add bash openssl curl

COPY --from=ex_builder /app/_build/prod/rel/ex_backend .
COPY --from=ex_builder /app/priv/static static/
COPY --from=ex_builder /app/documentation.json .

RUN backend="$(ls -1 lib/ | grep ex_backend)" && \
    rm -rf lib/$backend/priv/static/ && \
    mv static/ lib/$backend/priv/

HEALTHCHECK --interval=30s --start-period=2s --retries=2 --timeout=3s CMD curl -v --silent --fail http://localhost:8080/ || exit 1

CMD ["./bin/ex_backend", "foreground"]
