FROM elixir:1.3.2

RUN mix local.hex --force
RUN mix local.rebar --force

WORKDIR /ex_orient

CMD ["/bin/sh"]
