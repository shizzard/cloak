-module(cloak_transform).
-export([parse_transform/2]).
-include("cloak.hrl").


-ifdef(cloak_dump).
    maybe_dump_source(Forms0) ->
        DestFile = io_lib:format("~s/~s.erl", [?cloak_dump, (get(state))#state.module]),
        Forms1 = [?es:revert(T) || T <- lists:flatten(Forms0)],
        Forms2 = epp:restore_typed_record_fields(Forms1),
        Source = iolist_to_binary([erl_pp:form(Form) || Form <- Forms2]),
        io:format("Dumping '~s' source to ~s: ~p~n", [(get(state))#state.module, DestFile, file:write_file(DestFile, Source)]).
-else.
    maybe_dump_source(_Forms0) ->
        ok.
-endif.


parse_transform(Forms, _Options) ->
    put(state, #state{}),
    _Forms = cloak_collect:collect(Forms),
    GeneratedForms_new = cloak_generate_new:generate(Forms),
    GeneratedForms_update = cloak_generate_update:generate(Forms),
    GeneratedForms_getters = cloak_generate_getters:generate(Forms),
    GeneratedForms_setters = cloak_generate_setters:generate(Forms),
    GeneratedForms_export = cloak_generate_export:generate(Forms),
    GeneratedForms_validate_struct = cloak_generate_validate_struct:generate(Forms),
    GeneratedForms_validators = cloak_generate_validators:generate(Forms),
    GeneratedForms_errors = cloak_generate_errors:generate(Forms),
    GeneratedForms_exports = cloak_generate_exports:generate(Forms),
    MergedForms = do_merge_forms(Forms, lists:flatten([
        GeneratedForms_errors,
        GeneratedForms_exports,
        GeneratedForms_new,
        GeneratedForms_update,
        GeneratedForms_getters,
        GeneratedForms_setters,
        GeneratedForms_export,
        GeneratedForms_validate_struct,
        GeneratedForms_validators
    ])),
    maybe_dump_source(MergedForms),
    MergedForms.


do_merge_forms(OriginalForms, GeneratedForms) ->
    {PreForms, PostForms} = lists:splitwith(fun is_attribute/1, OriginalForms),
    MergedForms = [PreForms, GeneratedForms, PostForms],
    [?es:revert(Form) || Form <- lists:flatten(MergedForms)].


is_attribute(Form) ->
    ?es:type(Form) == attribute.
