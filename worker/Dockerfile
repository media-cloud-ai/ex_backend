FROM python:3.5-alpine

RUN pip install pika
ADD ./worker /app

CMD python /app/run.py
