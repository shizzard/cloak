-module(cloak_generate_getters).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    lists:flatten([
        [getter_spec__(RecordField), getter__(RecordField)] || RecordField
        <- ?get_state()#state.required_record_fields
        ++ ?get_state()#state.optional_record_fields
        ++ ?get_state()#state.protected_record_fields
    ]).


%% Getters


getter_spec__(#record_field{name = Name, type = Type}) ->
    cloak_generate:function_spec__(
        Name,
        _In = [
            ?es:annotated_type(
                cloak_generate:var__(in_maybe_record, 0),
                ?es:type_union([cloak_generate:opaque_type__(), cloak_generate:built_in_type__(term)])
            )
        ],
        _Out = ?es:annotated_type(
            cloak_generate:var__(out_value, 0),
            case Type of
                none -> ?es:type_union([cloak_generate:built_in_type__(term), cloak_generate:no_return_type__()]);
                Type -> ?es:type_union([Type, cloak_generate:no_return_type__()])
            end
        )
    ).


getter__(#record_field{name = Name}) ->
    ?put_state(?get_state()#state{export = [
        {Name, ?cloak_generated_function_getter_arity} | ?get_state()#state.export
    ]}),
    ?es:function(?es:atom(Name), getter_clauses__(Name)).


getter_clauses__(Name) ->
    [
        ?es:clause(
            getter_clause_patterns_match__(Name),
            _Guards = none,
            getter_clause_body_match__(Name)
        ),
        ?es:clause(
            getter_clause_patterns_mismatch__(Name),
            _Guards = none,
            getter_clause_body_mismatch__(Name)
        )
    ].


getter_clause_patterns_match__(Name) ->
    [?es:record_expr(
        ?es:atom(?get_state()#state.module),
        [?es:record_field(?es:atom(Name), cloak_generate:var__(Name, 0))]
    )].


getter_clause_body_match__(Name) ->
    [cloak_generate:var__(Name, 0)].


getter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore()].


getter_clause_body_mismatch__(_Name) ->
    [cloak_generate:error_badarg__()].
