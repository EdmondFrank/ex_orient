defmodule ExOrient.DB.Indexes do
  @moduledoc """

  """

  alias ExOrient.DB
  alias ExOrient.QueryBuilder, as: QB

  @doc """
  Create a new index.

      > ExOrient.DB.create(index: "name", on: "Movie (title)", index_type: :unique, key_type: :string)
      0

  """
  def create(opts \\ []) do
    name = Keyword.get(opts, :index)

    query = "CREATE INDEX #{name}"

    {query, params} =
      opts
      |> Keyword.get(:on)
      |> QB.append_on(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:index_type)
      |> QB.append_type(query, params)

    {query, params} =
      opts
      |> Keyword.get(:key_type)
      |> QB.append_type(query, params)

    {query, params} =
      opts
      |> Keyword.get(:metadata)
      |> QB.append_metadata(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Rebuild an index by name

      > ExOrient.DB.rebuild(index: "name")

  """
  def rebuild(opts \\ []) do
    name = Keyword.get(opts, :index)
    query = "REBUILD INDEX #{name}"
    DB.command(query)
  end

  @doc """
  Drop an index by name or property

      > ExOrient.DB.drop(index: "name")

  """
  def drop(opts \\ []) do
    name = Keyword.get(opts, :index)
    query = "DROP INDEX #{name}"
    DB.command(query)
  end
end
