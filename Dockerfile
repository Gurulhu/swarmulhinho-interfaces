FROM elixir:alpine

COPY lib ./lib
COPY config ./config
COPY mix.exs .
COPY mix.lock .

RUN export MIX_ENV=prod && \
  mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get


COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

CMD ["sh", "./entrypoint.sh"]
