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
    GeneratedForms = cloak_generate:generate(Forms),
    MergedForms = do_merge_forms(Forms, GeneratedForms),
    maybe_dump_source(MergedForms),
    MergedForms.


do_merge_forms(OriginalForms, GeneratedForms) ->
    {PreForms, PostForms} = lists:splitwith(fun is_attribute/1, OriginalForms),
    MergedForms = [PreForms, GeneratedForms, PostForms],
    [?es:revert(Form) || Form <- lists:flatten(MergedForms)].


is_attribute(Form) ->
    ?es:type(Form) == attribute.
