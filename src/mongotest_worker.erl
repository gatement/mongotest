-module(mongotest_worker).
-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([insert/2]).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {conn}).

%% ===================================================================
%% api functions
%% ===================================================================
insert(Collection, Params) ->
    poolboy:transaction(mongo_conn_pool, fun(Worker) ->
        gen_server:call(Worker, {insert, Collection, Params})
    end).

%% ===================================================================
%% poolboy_worker callbacks
%% ===================================================================
start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

%% ===================================================================
%% gen_server callbacks
%% ===================================================================
init(Args) ->
    process_flag(trap_exit, true),

    Host = proplists:get_value(host, Args),
    Port = proplists:get_value(port, Args),
    Database = proplists:get_value(database, Args),

    {ok, Conn} = mongo:connect([
                                {host, Host},
                                {port, Port},
                                {database, Database}
                               ]),

    {ok, #state{conn=Conn}}.

handle_call({insert, Collection, {Did, Timestamp, ProductKey, Type, Payload}}, _From, #state{conn=Conn}=State) ->
    Result = mongo:insert(Conn, Collection, #{<<"did">> => Did, 
                                              <<"timestamp">> => Timestamp,
                                              <<"product_key">> => ProductKey,
                                              <<"type">> => Type,
                                              <<"payload">> => Payload
                                             }),
    {reply, Result, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{conn=Conn}) ->
    io:format("conn existed with reason: ~p~n", [_Reason]),
    ok = mongo:disconnect(Conn),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
