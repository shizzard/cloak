-module(cloak_generate_validate_struct).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [default_validate_callback__(
        (get(state))#state.callback_validate_struct_exists
    )].


%% Default validate callback


default_validate_callback__(true) ->
    [];

default_validate_callback__(false) ->
    ?es:function(?es:atom(?cloak_callback_validate_struct), default_validate_callback_clauses__()).


default_validate_callback_clauses__() ->
    [?es:clause(
        default_validate_callback_clause_patterns_match__(),
        _Guards = none,
        default_validate_callback_clause_body_match__()
    )].


default_validate_callback_clause_patterns_match__() ->
    [cloak_generate:var__(value, 0)].


default_validate_callback_clause_body_match__() ->
    [?es:tuple([?es:atom(ok), cloak_generate:var__(value, 0)])].
