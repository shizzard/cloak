-module(cloak_generate).
-export([
    validator_function_name/1,
    generic_user_definable_getter_callback_name/1,
    generic_user_definable_setter_callback_name/1,
    generic_user_definable_validator_callback_name/1,
    generic_user_definable_export_callback_name/1
]).
-export([error_message__/2, error_badarg__/0, var__/2]).
-include("cloak.hrl").

-callback generate(Forms :: term()) -> [term()].


%% Generics


validator_function_name(FieldName) ->
    list_to_atom(lists:flatten(io_lib:format("validate_~s", [FieldName]))).


generic_user_definable_getter_callback_name(FieldName) ->
    list_to_atom(lists:flatten(io_lib:format("on_get_~s", [FieldName]))).


generic_user_definable_setter_callback_name(FieldName) ->
    list_to_atom(lists:flatten(io_lib:format("on_set_~s", [FieldName]))).


generic_user_definable_validator_callback_name(FieldName) ->
    list_to_atom(lists:flatten(io_lib:format("on_validate_~s", [FieldName]))).


generic_user_definable_export_callback_name(FieldName) ->
    list_to_atom(lists:flatten(io_lib:format("on_export_~s", [FieldName]))).


%% Generics (AST generators)


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
