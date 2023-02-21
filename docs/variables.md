# Environment variables

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
| `MCAI_RESET_ROOT_PASSWORD`                  |                              | If TRUE the root password is reset.         |
| `ROOT_EMAIL`           |                              | Application email for administrator.            |
| `HOSTNAME`             |                              | Application hostname (or IP).                   |
