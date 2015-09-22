-module(mongotest_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    {ok, PoolDefinitions} = application:get_env(mongo_conn_pool),
    PoolName = mongo_conn_pool,
    PoolArgs = [{name, {local, PoolName}},
                {worker_module, mongotest_worker}] ++ proplists:get_value(pool_params, PoolDefinitions),
    WorkerArgs = proplists:get_value(worker_params, PoolDefinitions),
    MongoConnPool = poolboy:child_spec(PoolName, PoolArgs, WorkerArgs),

    {ok, {{one_for_one, 10, 10}, [MongoConnPool]}}.

