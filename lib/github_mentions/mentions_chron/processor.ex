defmodule GithubMentions.Processor do
    use GenServer

    def init([]) do 
        {:ok, []}
    end

    def start_link(state) do
        GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    def process(data) do
        handle_call(:process, nil, data)
    end

    def handle_call(:process, _from, data) do
        IO.inspect(data, label: "Data to process --")
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