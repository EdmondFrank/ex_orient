defmodule ExOrient.DB do
  @moduledoc """
  MarcoPolo ExOrientDB wrapper that provides a clean syntax for queries. This
  module simply routes SQL commands to the correct submodule, providing the
  ability to call all commands through ExOrient.DB.<command>
  """

  alias ExOrient.DB.CRUD, as: CRUD
  alias ExOrient.DB.Graph, as: Graph
  alias ExOrient.DB.Indexes, as: Indexes
  alias ExOrient.DB.Schema, as: Schema

  @doc """
  Execute a raw query with MarcoPolo and return the response.

      ExOrient.DB.command("SELECT FROM ProgrammingLanguage")
      # [%MarcoPolo.Document{class: "ProgrammingLanguage", fields: _, rid: _, version: _} | _rest]

  Only use this function directly if you need the power of a raw query. Be sure
  to use the params argument if you need to bind variables:

      ExOrient.DB.command("SELECT FROM ProgrammingLanguage WHERE name = :name", params: %{name: "Elixir"})

  """
  def command({query, params}), do: command(query, params: params)
  def command(query), do: command(query, params: [])
  def command(query, params: params) do
    :poolboy.transaction(:marco_polo, fn(worker) ->
      case MarcoPolo.command(worker, query, params: params) do
        {:ok, %{response: response}} -> {:ok, response}
        {:error, error} -> {:error, error}
        _ -> {:error, "Something went badly wrong."}
      end
    end)
  end

  @doc """
  An alias for command/1
  """
  def exec({query, params}), do: command(query, params: params)

  defdelegate select(field), to: CRUD
  defdelegate select(field, opts), to: CRUD
  defdelegate rid(rid), to: CRUD
  defdelegate insert(opts), to: CRUD
  defdelegate update(obj, opts), to: CRUD
  defdelegate truncate(opts), to: CRUD

  def delete(opts \\ []) do
    cond do
      Keyword.get(opts, :vertex) -> Graph.delete(opts)
      Keyword.get(opts, :edge) -> Graph.delete(opts)
      true -> CRUD.delete(opts)
    end
  end

  def create(opts \\ []) do
    cond do
      Keyword.get(opts, :vertex) -> Graph.create_vertex(opts)
      Keyword.get(opts, :edge) -> Graph.create_edge(opts)
      Keyword.get(opts, :class) -> Schema.create_class(opts)
      Keyword.get(opts, :property) -> Schema.create_property(opts)
      Keyword.get(opts, :index) -> Indexes.create(opts)
      true -> {:error, "Invalid command"}
    end
  end

  def alter(opts \\ []) do
    cond do
      Keyword.get(opts, :class) -> Schema.alter_class(opts)
      Keyword.get(opts, :property) -> Schema.alter_property(opts)
      true -> {:error, "Invalid command"}
    end
  end

  def drop(opts \\ []) do
    cond do
      Keyword.get(opts, :class) -> Schema.drop_class(opts)
      Keyword.get(opts, :property) -> Schema.drop_property(opts)
      Keyword.get(opts, :index) -> Indexes.drop(opts)
      true -> {:error, "Invalid command"}
    end
  end

  defdelegate rebuild(opts), to: Indexes
end
