defmodule ExOrient.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    :random.seed()

    pool_options = [
      name: {:local, :marco_polo},
      worker_module: MarcoPolo,
      size: pool_size(),
      max_overflow: pool_max_overflow()
    ]

    args = [
      user: user(),
      password: password(),
      connection: connection(),
      host: host(),
      port: port()
    ]

    children = [
      :poolboy.child_spec(:marco_polo, pool_options, args)
    ]

    supervise(children, strategy: :one_for_one)
  end

  defp pool_size, do: Application.get_env(:ex_orient, :pool_size)
  defp pool_max_overflow, do: Application.get_env(:ex_orient, :pool_max_overflow)
  defp user, do: Application.get_env(:ex_orient, :user)
  defp password, do: Application.get_env(:ex_orient, :password)
  defp connection, do: Application.get_env(:ex_orient, :connection)
  defp host, do: Application.get_env(:ex_orient, :host)
  defp port, do: Application.get_env(:ex_orient, :port)
end
