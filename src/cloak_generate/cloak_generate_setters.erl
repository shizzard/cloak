-module(cloak_generate_setters).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    lists:flatten([
        [setter_spec__(RecordField), setter__(RecordField)] || RecordField
        <- ?get_state()#state.required_record_fields ++ ?get_state()#state.optional_record_fields
    ]).


%% Setters (?MODULE:set_{FIELD}/2)


setter_spec__(#record_field{name = Name, type = Type}) ->
    cloak_generate:function_spec__(
        Name,
        _In = [
            ?es:annotated_type(
                cloak_generate:var__(in_value, 0),
                case Type of
                    none -> cloak_generate:built_in_type__(term);
                    Type -> ?es:type_union([Type, cloak_generate:built_in_type__(term)])
                end
            ),
            ?es:annotated_type(
                cloak_generate:var__(in_maybe_record, 0),
                ?es:type_union([cloak_generate:opaque_type__(), cloak_generate:built_in_type__(term)])
            )
        ],
        _Out = ?es:annotated_type(
            cloak_generate:var__(out_record, 0),
            ?es:type_union([cloak_generate:opaque_type__(), cloak_generate:no_return_type__()])
        )
    ).


setter__(#record_field{name = Name}) ->
    ?put_state(?get_state()#state{export = [
        {Name, ?cloak_generated_function_setter_arity} | ?get_state()#state.export
    ]}),
    ?es:function(?es:atom(Name), setter_clauses__(Name)).


setter_clauses__(Name) ->
    [
        ?es:clause(
            setter_clause_patterns_match__(Name),
            _Guards = none,
            setter_clause_body_match__(Name)
        ),
        ?es:clause(
            setter_clause_patterns_mismatch__(Name),
            _Guards = none,
            setter_clause_body_mismatch__(Name)
        )
    ].


setter_clause_patterns_match__(_Name) ->
    [
        cloak_generate:var__(value, 0),
        ?es:match_expr(
            ?es:record_expr(?es:atom(?get_state()#state.module), []),
            cloak_generate:var__(record, 0)
        )
    ].


setter_clause_body_match__(Name) ->
    [?es:application(?es:atom(?cloak_generated_function_i_on_update), [
        ?es:application(?es:atom(?cloak_generated_function_i_set), [
            ?es:atom(Name),
            cloak_generate:var__(value, 0),
            cloak_generate:var__(record, 0)
        ])
    ])].


setter_clause_patterns_mismatch__(_Name) ->
    [?es:underscore(), ?es:underscore()].


setter_clause_body_mismatch__(_Name) ->
    [cloak_generate:error_badarg__()].
