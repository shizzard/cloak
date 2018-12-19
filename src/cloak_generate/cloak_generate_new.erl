-module(cloak_generate_new).
-behaviour(cloak_generate).
-export([generate/1]).
-include("cloak.hrl").


%% Generate callback


generate(_Forms) ->
    [new__()].


%% New


new__() ->
    ?put_state(?get_state()#state{export = [
        {?cloak_generated_function_new, ?cloak_generated_function_new_arity} | ?get_state()#state.export
    ]}),
    [?es:function(?es:atom(?cloak_generated_function_new), new_clauses__())].


new_clauses__() ->
    [
        ?es:clause(new_clause_patterns_match__(), _Guards = none, new_clause_body_match__()),
        ?es:clause(new_clause_patterns_mismatch__(), _Guards = none, new_clause_body_mismatch__())
    ].


new_clause_patterns_match__() ->
    [?es:match_expr(?es:map_expr([]), cloak_generate:var__(map, 0))].


new_clause_body_match__() ->
    [?es:application(?es:atom(?cloak_generated_function_i_on_update), [
        ?es:application(?es:atom(?cloak_generated_function_i_new_optional), [
            cloak_generate:var__(map, 0),
            ?es:application(?es:atom(?cloak_generated_function_i_new_required), [
                cloak_generate:var__(map, 0),
                ?es:record_expr(?es:atom(?get_state()#state.module), []),
                ?es:list([
                    ?es:tuple([
                        ?es:atom(RequiredField#record_field.name),
                        ?es:abstract(RequiredField#record_field.binary_name)
                    ]) || RequiredField <- ?get_state()#state.required_record_fields
                ])
            ]),
            ?es:list([
                ?es:tuple([
                    ?es:atom(OptionalField#record_field.name),
                    ?es:abstract(OptionalField#record_field.binary_name)
                ]) || OptionalField <- ?get_state()#state.optional_record_fields
            ])
        ])
    ])].


new_clause_patterns_mismatch__() ->
    [?es:underscore()].


new_clause_body_mismatch__() ->
    [cloak_generate:error_badarg__()].
