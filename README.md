# ExBackend

At this moment, the backend is composed of 2 parts:

1. Back-end in Elixir which provide API,
2. Front-End in Angular which consume API from back-end.

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

## Front-End

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

Some variables are defined to apply a custom setting. These variables are:

| Variable name          | Default value                | Description                                     |
|------------------------|------------------------------|-------------------------------------------------|
| `AMQP_HOSTNAME`        | `127.0.0.1`                  | IP or host of AMQP server.                      |
| `AMQP_PORT`            | `5672`                       | AMQP server port.                               |
| `AMQP_USERNAME`        | `guest`                      | User name used to connect to AMQP server.       |
| `AMQP_PASSWORD`        | `guest`                      | Password used to connect to AMQP server.        |
| `AMQP_VHOST`           | `/`                          | AMQP vhost.                                     |
| `AMQP_TLS`             | `true`                       | Set to TRUE is HTTPS is activated.              |
| `AMQP_MANAGEMENT_PORT` |                              | Port used to query RabbitMQ and get admin data. |
| `DATABASE_NAME`        |                              | Name of the database used.                      |
| `DATABASE_PORT`        |                              | Port of the database used.                      |
| `DATABASE_PASSWORD`    |                              | Database password.                              |
| `DATABASE_USERNAME`    |                              | Database login.                                 |
| `DATABASE_HOSTNAME`    |                              | Host of the database (IP or DNS).               |
| `PORT`                 |                              | Port to access the application.                 |
| `SSL`                  |                              | If TRUE the application run with HTTPS.         |
| `ROOT_PASSWORD`        | `admin123`                   | Application password for administrator.         |
| `ROOT_EMAIL`           |                              | Application email for administrator.            |
| `HOSTNAME`             |                              | Application hostname (or IP).                   |

# Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

