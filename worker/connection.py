
import os
import json
import time
import pika
import logging

class Connection:

    def get_parameter(self, key, param, default):
        key = "RMQ_" + key
        if key in os.environ:
            return os.environ.get(key)

        return default

    def load_configuration(self):
        self.rmq_username = self.get_parameter('USER', 'username', 'guest')
        self.rmq_password = self.get_parameter('PWD', 'password', 'guest')
        self.rmq_vhost    = self.get_parameter('VHOST', 'vhost', '')
        self.rmq_hostname = self.get_parameter('HOSTNAME', 'hostname', 'localhost')
        port = self.get_parameter('PORT', 'port', 5672)
        self.rmq_port     = int(port)

    def connect(self, queues):
        credentials = pika.PlainCredentials(
            self.rmq_username,
            self.rmq_password
        )

        parameters = pika.ConnectionParameters(
            self.rmq_hostname,
            self.rmq_port,
            self.rmq_vhost,
            credentials
        )

        logging.info("Connection to RabbitMQ")
        logging.info(self.rmq_hostname)
        logging.info(self.rmq_port)
        logging.info(self.rmq_vhost)

        time.sleep(3)
        connection = pika.BlockingConnection(parameters)
        self.connection = connection
        channel = connection.channel()
        logging.info("Connected")
        for queue in queues:
            channel.queue_declare(queue=queue, durable=False)
        self.channel = channel

    def consume(self, queue, callback):
        self.channel.basic_consume(callback,
                      queue=queue,
                      no_ack=False)

        logging.info('Service started, waiting messages ...')
        self.channel.start_consuming()

    def send(self, queue, message):
        self.channel.basic_publish(
            exchange = '',
            routing_key = queue,
            body = message
        )

    def sendJson(self, queue, message):
        logging.info(message)
        encodedMessage = json.dumps(message, ensure_ascii=False)
        self.send(queue, encodedMessage)

    def close(self):
        logging.info("close RabbitMQ connection")
        self.connection.close()
