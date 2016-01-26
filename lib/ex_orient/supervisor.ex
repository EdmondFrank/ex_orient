defmodule ExOrient.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    pool_options = [
      name: {:local, :marco_polo},
      worker_module: MarcoPolo,
      size: 5,
      max_overflow: 10
    ]

    children = [
      :poolboy.child_spec(:marco_polo, pool_options, [user: "admin", password: "admin", connection: {:db, "GratefulDeadConcerts", :document}])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
