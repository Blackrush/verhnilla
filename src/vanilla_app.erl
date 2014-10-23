-module(vanilla_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
	application:start(ranch),
	application:start(vanilla),
	ok.

start(_StartType, _StartArgs) ->
    vanilla_sup:start_link().

stop(_State) ->
    ok.
