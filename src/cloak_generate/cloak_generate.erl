-module(cloak_generate).
-export([
    set_nested_substructure_module/2,
    get_nested_substructure_module/1,
    set_nested_substructure_list_module/2,
    get_nested_substructure_list_module/1
]).
-export([
    error_compile_time__/1, error_compile_time__/2,
    error_message__/2, error_badarg__/0, var__/2,
    function_spec__/3, built_in_type__/1, no_return_type__/0, opaque_type__/0
]).
-include("cloak.hrl").

-callback generate(Forms :: term()) -> [term()].


%% Generics


set_nested_substructure_module(FieldName, SubstructureModule) ->
    ?put_state(?get_state()#state{
        nested_substructures = [
            {FieldName, SubstructureModule}
            | ?get_state()#state.nested_substructures
        ]
    }).


get_nested_substructure_module(FieldName) ->
    case proplists:lookup(FieldName, ?get_state()#state.nested_substructures) of
        {FieldName, SubstructureModule} ->
            SubstructureModule;
        none ->
            undefined
    end.


set_nested_substructure_list_module(FieldName, SubstructureModule) ->
    ?put_state(?get_state()#state{
        nested_substructures_list = [
            {FieldName, SubstructureModule}
            | ?get_state()#state.nested_substructures_list
        ]
    }).


get_nested_substructure_list_module(FieldName) ->
    case proplists:lookup(FieldName, ?get_state()#state.nested_substructures_list) of
        {FieldName, SubstructureModule} ->
            SubstructureModule;
        none ->
            undefined
    end.


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


error_compile_time__(Reason) ->
    error_compile_time__(0, Reason).


error_compile_time__(Line, Reason) ->
    {error, {Line, cloak_transform, Reason}}.


error_badarg__() ->
    ?es:application(?es:atom(error), [?es:atom(badarg)]).


var__(Name, Num) ->
    VarName = lists:flatten(io_lib:format("~s_~s_~B", ["Var", Name, Num])),
    ?es:variable(VarName).


%% Typespecs (AST generators)


function_spec__(FunctionName, ArgsTypes, RetType) ->
    ?es:attribute(?es:atom(spec), [
        ?es:tuple([
            ?es:tuple([?es:atom(FunctionName), ?es:integer(length(ArgsTypes))]),
            %% This is a strange approach, but it does work;
            %% doesn't work without revert/abstract calls though.
            %% Definitely a place to revisit in future.
            ?es:abstract([?es:revert(?es:function_type(ArgsTypes, RetType))])
        ])
    ]).


built_in_type__(Type) ->
    ?es:type_application(?es:atom(Type), []).


no_return_type__() ->
    built_in_type__(no_return).


opaque_type__() ->
    ?es:type_application(?es:atom(term), []).
    %?es:type_application(?es:atom(?get_state()#state.module), ?es:atom(t), []).
