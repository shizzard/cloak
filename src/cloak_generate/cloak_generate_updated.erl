-module(cloak_generate_updated).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [default_updated_callback__(
        (get(state))#state.callback_updated_exists
    )].


%% Default updated callback


default_updated_callback__(true) ->
    [];

default_updated_callback__(false) ->
    ?es:function(?es:atom(?cloak_callback_updated), default_updated_callback_clauses__()).


default_updated_callback_clauses__() ->
    [?es:clause(
        default_updated_callback_clause_patterns_match__(),
        _Guards = none,
        default_updated_callback_clause_body_match__()
    )].


default_updated_callback_clause_patterns_match__() ->
    [?es:underscore(), cloak_generate:var__(record, 0)].


default_updated_callback_clause_body_match__() ->
    [cloak_generate:var__(record, 0)].
