#!/usr/bin/env sh

sed -i "s/NADIA_TELEGRAM_TOKEN/${NADIA_TELEGRAM_TOKEN}/g" ./config/config.exs
sed -i "s/AMQP_SERVER_STRING/${AMQP_SERVER_STRING}/g" ./config/config.exs

mix run --no-halt
