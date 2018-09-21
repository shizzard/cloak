-module(cloak_generate).
-export([error_message__/2, error_badarg__/0, var__/2]).
-include("cloak.hrl").

-callback generate(Forms :: term()) -> [term()].


%% Generics


-ifndef(cloak_suppress_logging).
    error_message__(Format, Args) ->
        ?es:application(
            ?es:module_qualifier(?es:atom(error_logger), ?es:atom(error_msg)),
            [?es:string(Format), ?es:list(Args)]
        ).
-else.
    error_message__(Format, Args) when ?cloak_suppress_logging ->
        ?es:match_expr(
            ?es:underscore(),
            ?es:tuple([
                ?es:atom(suppressed_logging),
                ?es:string(Format),
                ?es:list(Args)
            ])
        ).
-endif.


error_badarg__() ->
    ?es:application(?es:atom(error), [?es:atom(badarg)]).


var__(Name, Num) ->
    VarName = lists:flatten(io_lib:format("~s_~s_~B", ["Var", Name, Num])),
    ?es:variable(VarName).
