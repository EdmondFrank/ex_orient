defmodule ExOrient do
  @moduledoc """
  The root application that starts the supervisor
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children =
    if auto_start?() do
      [supervisor(ExOrient.Supervisor, [])]
    else
      []
    end

    children =
    if auto_start?() && keep_alive?() do
      children ++ [supervisor(ExOrient.KeepAlive.Supervisor, [])]
    else
      children
    end

    opts = [strategy: :one_for_one, name: ExOrient]
    Supervisor.start_link(children, opts)
  end

  defp keep_alive? do
    Application.get_env(:ex_orient, :keep_alive)
  end

  defp auto_start? do
    Application.get_env(:ex_orient, :auto_start)
  end
end
