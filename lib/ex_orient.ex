defmodule ExOrient do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(ExOrient.Supervisor, [])
    ]

    opts = [strategy: :one_for_one, name: ExOrient]
    Supervisor.start_link(children, opts)
  end
end
