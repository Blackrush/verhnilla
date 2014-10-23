-module(vanilla_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(WORKER(I, Args), {I, {I, start_link, Args}, permanent, 5000, worker, [I]}).
-define(SUPERVISOR(I), {I, {I, start_link, []}, permanent, 5000, supervisor, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
	Children = [
				?WORKER(vanilla_tcp, [])
			   ],
    {ok, { {one_for_one, 5, 10}, Children} }.

