defmodule ExOrient.DB.Schema do
  @moduledoc """
  Schema command bindings
  """

  alias ExOrient.QueryBuilder, as: QB

  @doc """
  Create a class command

      ExOrient.DB.create(class: Vehicle, abstract: true)

      ExOrient.DB.create(class: Car, extends: Vehicle)

  """
  def create_class(opts \\ []) do
    class =
      opts
      |> Keyword.get(:class)
      |> QB.class_name()

    query = "CREATE CLASS #{class}"

    {query, params} =
      opts
      |> Keyword.get(:extends)
      |> QB.append_extends(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:cluster)
      |> QB.append_cluster(query, params)

    {query, params} =
      opts
      |> Keyword.get(:abstract)
      |> QB.append_abstract(query, params)

    {query, params}
  end

  @doc """
  Create property command

      ExOrient.DB.create(property: "Car.make", type: :string)

      ExOrient.DB.create(property: "Car.model", type: :string)

  """
  def create_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    type = Keyword.get(opts, :type) |> to_string() |> String.upcase()
    query = "CREATE PROPERTY #{property} #{type}"

    {query, params} =
      opts
      |> Keyword.get(:unsafe)
      |> QB.append_unsafe(query, %{})

    {query, params}
  end

  @doc """
  Alter class command

      ExOrient.DB.alter(class: Cow, attr: "SUPERCLASS Animal")

  """
  def alter_class(opts \\ []) do
    class = Keyword.get(opts, :class) |> QB.class_name()
    attr = Keyword.get(opts, :attr)
    query = "ALTER CLASS #{class} #{attr}"
    {query, %{}}
  end

  @doc """
  Alter property command

      ExOrient.DB.alter(property: "Car.model", attr: "MANDATORY true")

  """
  def alter_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    attr = Keyword.get(opts, :attr)
    query = "ALTER PROPERTY #{property} #{attr}"
    {query, %{}}
  end

  @doc """
  Drop class command

      ExOrient.DB.drop(class: Cow)

  """
  def drop_class(opts \\ []) do
    class = Keyword.get(opts, :class) |> QB.class_name()
    query = "DROP CLASS #{class}"

    {query, params} =
      opts
      |> Keyword.get(:unsafe)
      |> QB.append_unsafe(query, %{})

    {query, params}
  end

  @doc """
  Drop property command

      ExOrient.DB.drop(property: "Car.model")

  """
  def drop_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    query = "DROP PROPERTY #{property}"

    {query, params} =
      opts
      |> Keyword.get(:force)
      |> QB.append_force(query, %{})

    {query, params}
  end
end
