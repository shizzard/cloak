-module(cloak_generate_exports).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [exports__()].


%% Export attribute


exports__() ->
    [?es:attribute(
        ?es:atom(export), [
            ?es:list(lists:map(fun({Function, Arity}) ->
                ?es:arity_qualifier(?es:atom(Function), ?es:integer(Arity))
            end, ?get_state()#state.export))
        ]
    )].
