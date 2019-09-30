# ExBackend

At this moment, the backend is composed of 2 parts:

1. Back-end in Elixir which provide API,
2. Front-end in Angular which consume API from back-end.

## Requirements

The following tool must be installed on your computer:

* Elixir development environment (see installation [here](https://elixir-lang.org/install.html))

## Back-End

### Installation

Backend installation:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * To run the application locally in dev mode, in the config folder, you need to create a file `dev.secret.exs` which will contains `use Mix.Config`

### Start back-end server locally

Start Phoenix endpoint with `mix phx.server`

## Front-end

### Installation 

Install Node.js dependencies with : `cd assets && yarn install`

### Launch front server locally

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Makefile targets

Commands below will be used for both stacks (backend & workers):

| Command                     | Description                                                                                |
|-----------------------------|--------------------------------------------------------------------------------------------|
| `make docker-build`         | Build locally a docker image                                                               |
| `make docker-clean`         | Remove locally the built docker image                                                      |
| `make docker-push-registry` | Push the locally built docker image                                                        |
| `make up`                   | Launch both, the back and front end locally [http://localhost:4000](http://localhost:4000) |

## Environment variables

Some variables are defined to apply a custom setting. These variables are listed [here](docs/variables.md)

# Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

