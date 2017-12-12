REBAR = ./rebar3

.PHONY: all clean compile dialyze test

all: compile

clean:
	$(REBAR) clean

compile:
	$(REBAR) compile

compile-debug:
	ERL_COMPILER_OPTIONS='[{d, cloak_dump, "temp"}]' \
	$(REBAR) compile

dialyze:
	$(REBAR) dialyzer

test:
	ERL_COMPILER_OPTIONS='[{d, cloak_dump, "temp"}]' \
	$(REBAR) eunit
