defmodule ExOrient.DB.Graph do
  @moduledoc """
  Provides Graph commands
  """

  alias ExOrient.DB
  alias ExOrient.QueryBuilder, as: QB

  @doc """
  Create a vertex or edge. Examples:

      > ExOrient.DB.create_vertex(vertex: "V", set: [name: "Steve"])
      %MarcoPolo.Document{class: "V", fields: %{"name" => "Steve"}, rid: _, version: _}

      > ExOrient.DB.create_vertex(vertex: "V", content: %{name: "Bob"})
      %MarcoPolo.Document{class: "V", fields: %{"name" => "Bob"}, rid: _, version: _}

  """
  def create_vertex(opts \\ []) do
    class =
      opts
      |> Keyword.get(:vertex)
      |> QB.class_name()

    query = "CREATE VERTEX #{class}"

    {query, params} =
      opts
      |> Keyword.get(:cluster)
      |> QB.append_cluster(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:set)
      |> QB.append_set(query, params)

    {query, params} =
      opts
      |> Keyword.get(:content)
      |> QB.append_content(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Create an edge. Examples:

      > ExOrient.DB.create(edge: "E", from: "#15:5", to: "#15:6", content: %{name: "Hello"})
      [%MarcoPolo.Document{class: "E", fields: %{"in" => #MarcoPolo.RID<#15:6>,
      "name" => "Hello", "out" => #MarcoPolo.RID<#15:5>}, rid: _, version: _}]

  """
  def create_edge(opts \\ []) do
    class =
      opts
      |> Keyword.get(:edge)
      |> QB.class_name()

    query = "CREATE EDGE #{class}"

    {query, params} =
      opts
      |> Keyword.get(:cluster)
      |> QB.append_cluster(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:from)
      |> QB.append_from(query, params)

    {query, params} =
      opts
      |> Keyword.get(:to)
      |> QB.append_to(query, params)

    {query, params} =
      opts
      |> Keyword.get(:set)
      |> QB.append_set(query, params)

    {query, params} =
      opts
      |> Keyword.get(:content)
      |> QB.append_content(query, params)

    {query, params} =
      opts
      |> Keyword.get(:retry)
      |> QB.append_retry(query, params)

    {query, params} =
      opts
      |> Keyword.get(:wait)
      |> QB.append_wait(query, params)

    {query, params} =
      opts
      |> Keyword.get(:batch)
      |> QB.append_batch(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Run a delete vertex or edge command. Examples:

      > DB.delete(vertex: "V", where: %{make: "Ford"})
      8

      > DB.delete(edge: "E", where: %{type: "Truck"})
      3

  """
  def delete(opts \\ []) do
    query = "DELETE"

    {query, params} =
      opts
      |> Keyword.get(:vertex)
      |> QB.append_vertex(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:edge)
      |> QB.append_edge(query, params)

    {query, params} =
      opts
      |> Keyword.get(:where)
      |> QB.append_where(query, params)

    {query, params} =
      opts
      |> Keyword.get(:limit)
      |> QB.append_limit(query, params)

    {query, params} =
      opts
      |> Keyword.get(:batch)
      |> QB.append_batch(query, params)

    DB.command(query, params: params)
  end
end
