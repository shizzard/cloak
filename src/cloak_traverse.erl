-module(cloak_traverse).
-export([traverse/2]).
-include("cloak.hrl").

%% Interface



traverse(Fun, Tree0) ->
    %io:format("~p~n", [?es:type(Tree0)]),
    Tree1 = case ?es:subtrees(Tree0) of
        [] ->
            Tree0;
        List ->
            ?es:update_tree(
                Tree0,
                [[traverse(Fun, Subtree) || Subtree <- Group] || Group <- List]
            )
    end,
    Fun(?es:type(Tree1), Tree1).
