defmodule GithubMentions.Processor do
    @moduledoc """
    Processing of Github mentions is done in this module.
    
    """

    use GenServer

    require Logger

    def init([]) do 
        Logger.info("Starting #{__MODULE__} server")
        {:ok, []}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    def process(data) do
        handle_call(:process, nil, data)
    end

    def handle_call(:process, _from, data) do
        Logger.info("Processing Data ...")
        pr_mentions = %{}
        comment_mentions = %{}

        {:reply, {pr_mentions, comment_mentions}}
    end

    # def handle_cast({:process, head}, tail) do
    #     {:noreply, [head | tail]}

    #     pr_mentions = %{}
    #     comment_mentions = %{}

    #     {:noreply, {pr_mentions, comment_mentions}}
    # end
end