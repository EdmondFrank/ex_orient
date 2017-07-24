defmodule ExOrient.KeepAlive.Worker do
  use GenServer

  @interval 60 * 1000

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    Process.send_after(self(), :keep_alive, @interval)
    {:ok, state}
  end

  def handle_info(:keep_alive, state) do
    :marco_polo
    |> GenServer.call(:get_all_workers)
    |> Enum.each(fn({_, pid, _, _}) ->
      MarcoPolo.command(pid, "SELECT FROM OUser LIMIT 1")
    end)

    Process.send_after(self(), :keep_alive, @interval)
    {:noreply, state}
  end
end
