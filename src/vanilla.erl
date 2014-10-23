-module(vanilla).

%% ==========================
%% convenient shell API
%% ==========================
-export([start/0, stop/0]).

-define(APPS, [
		   compiler,
		   syntax_tools,
		   goldrush,
		   lager,
		   ranch,
		   vanilla
		 ]).

start(App) when is_atom(App) ->
	case application:start(App) of
		ok -> ok;
		{error, {already_started, _}} -> ok;
		E={error, _Reason} -> E
	end;

start([]) -> ok;

start([App|Apps]) ->
	case start(App) of
		ok -> start(Apps);
		E -> E
	end.

stop(App) when is_atom(App) ->
	application:stop(App);

stop([]) -> ok;

stop([App|Apps]) ->
	stop(Apps),
	stop(App).

start() ->
	ok = start(?APPS),
	lager:set_loglevel(lager_console_backend, debug),
	lager:info("vanilla started up"),
	ok.

stop() ->
	lager:info("vanilla is shutting down"),
	stop(?APPS).
