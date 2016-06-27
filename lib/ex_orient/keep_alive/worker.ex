defmodule ExOrient.KeepAlive.Worker do
  use GenServer
  alias ExOrient.DB

  @interval 60 * 1000

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def init(state) do
    Process.send_after(self, :keep_alive, @interval)
    {:ok, state}
  end

  def handle_info(:keep_alive, state) do
    DB.select(from: "OUser", limit: 1) |> DB.exec()

    Process.send_after(self, :keep_alive, @interval)
    {:noreply, state}
  end
end
