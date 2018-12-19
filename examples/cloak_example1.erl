-module(cloak_example1).
-compile({parse_transform, cloak_transform}).

-record(?MODULE, {one, two, three}).
