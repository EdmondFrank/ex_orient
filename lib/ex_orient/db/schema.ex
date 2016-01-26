defmodule ExOrient.DB.Schema do
  @moduledoc """
  Schema command bindings
  """

  alias ExOrient.DB
  alias ExOrient.QueryBuilder, as: QB

  @doc """
  Create a class command

      > ExOrient.DB.create(class: Vehicle, abstract: true)
      17

      > ExOrient.DB.create(class: Car, extends: Vehicle)
      18

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

    DB.command(query, params: params)
  end

  @doc """
  Create property command

      > ExOrient.DB.create(property: "Car.make", type: :string)
      1

      > ExOrient.DB.create(property: "Car.model", type: :string)
      2

  """
  def create_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    type = Keyword.get(opts, :type) |> to_string() |> String.upcase()
    query = "CREATE PROPERTY #{property} #{type}"
    DB.command(query)
  end

  @doc """
  Alter class command

      > ExOrient.DB.alter(class: Cow, attr: "SUPERCLASS Animal")
      nil

  """
  def alter_class(opts \\ []) do
    class = Keyword.get(opts, :class) |> QB.class_name()
    attr = Keyword.get(opts, :attr)
    query = "ALTER CLASS #{class} #{attr}"
    DB.command(query)
  end

  @doc """
  Alter property command

      > ExOrient.DB.alter(property: "Car.model", attr: "MANDATORY true")
      nil

  """
  def alter_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    attr = Keyword.get(opts, :attr)
    query = "ALTER PROPERTY #{property} #{attr}"
    DB.command(query)
  end

  @doc """
  Drop class command

      > ExOrient.DB.drop(class: Cow)
      true

  """
  def drop_class(opts \\ []) do
    class = Keyword.get(opts, :class) |> QB.class_name()
    query = "DROP CLASS #{class}"
    DB.command(query)
  end

  @doc """
  Drop property command

      > ExOrient.DB.drop(property: "Car.model")
      nil

  """
  def drop_property(opts \\ []) do
    property = Keyword.get(opts, :property)
    query = "DROP PROPERTY #{property}"
    DB.command(query)
  end
end
