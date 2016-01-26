defmodule ExOrient.DB.CRUD do
  @moduledoc """
  Provides CRUD commands
  """

  alias ExOrient.DB
  alias ExOrient.QueryBuilder, as: QB

  @doc """
  Perform a select operation. Examples:

      ExOrient.DB.select(from: ProgrammingLanguage)
      ExOrient.DB.select([:name], from: {ProgrammingLanguage})
      ExOrient.DB.select(from: ProgrammingLanguage, where: %{name: "Elixir"})
      ExOrient.DB.select(from: ProgrammingLanguage, where: %{name: "Elixir", type: "Awesome"})
      ExOrient.DB.select(from: ProgrammingLanguage, where: %{name: "Elixir", type: "Awesome"}, logical: "OR")
      ExOrient.DB.select(from: ProgrammingLanguage, where: %{"name.toLowerCase()" => "lolcode"})
      ExOrient.DB.select(from: ProgrammingLanguage, where: {"name.length()", ">", 10})
      ExOrient.DB.select(from: ProgrammingLanguage,
                       where: [{"name.length()", ">", 10},
                               {"name.left(2)", "=", "El"}],
                       logical: "OR")

  """
  def select(fields \\ [], opts) do
    fields =
      fields
      |> Enum.map(&to_string/1)
      |> Enum.join(", ")

    from =
      opts
      |> Keyword.get(:from)
      |> QB.class_name()

    query = "SELECT #{fields} FROM #{from}"

    {query, params} =
      opts
      |> Keyword.get(:let)
      |> QB.append_let(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:where)
      |> QB.append_where(Keyword.get(opts, :logical, "AND"), query, params)

    {query, params} =
      opts
      |> Keyword.get(:group_by)
      |> QB.append_group_by(query, params)

    {query, params} =
      opts
      |> Keyword.get(:order_by)
      |> QB.append_order_by(Keyword.get(opts, :order, "ASC"), query, params)

    {query, params} =
      opts
      |> Keyword.get(:unwind)
      |> QB.append_unwind(query, params)

    {query, params} =
      opts
      |> Keyword.get(:skip)
      |> QB.append_skip(query, params)

    {query, params} =
      opts
      |> Keyword.get(:limit)
      |> QB.append_limit(query, params)

    {query, params} =
      opts
      |> Keyword.get(:fetchplan)
      |> QB.append_fetchplan(query, params)

    {query, params} =
      opts
      |> Keyword.get(:timeout)
      |> QB.append_timeout(query, params)

    {query, params} =
      opts
      |> Keyword.get(:lock)
      |> QB.append_lock(query, params)

    {query, params} =
      opts
      |> Keyword.get(:parallel)
      |> QB.append_parallel(query, params)

    {query, params} =
      opts
      |> Keyword.get(:nocache)
      |> QB.append_nocache(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Shortcut function to easily select by Record ID. Takes a string or
  a %MarcoPolo.Rid{}.

      > ExOrient.DB.rid("#9:0")
      %MarcoPolo.Document{}

      > ExOrient.DB.rid(%MarcoPolo.RID{cluster_id: 9, position: 0})
      %MarcoPolo.Document{}

  """
  def rid(%MarcoPolo.RID{cluster_id: cid, position: pos}), do: rid("##{cid}:#{pos}")
  def rid(rid) do
    [doc | _] = select(from: rid)
    doc
  end

  @doc """
  Insert into the database. Compatible with various styles of syntax. Examples:

      > ExOrient.DB.insert(into: ProgrammingLanguage, values: {[:name], ["Elixir"]})
      %MarcoPolo.Document{class: "ProgrammingLanguage", fields: %{"name" => "Elixir"}, rid: _, version: _}

      > ExOrient.DB.insert(into: ProgrammingLanguage, set: [name: "Elixir"])
      %MarcoPolo.Document{class: "ProgrammingLanguage", fields: %{"name" => "Elixir"}, rid: _, version: _}

      > ExOrient.DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
      %MarcoPolo.Document{class: "ProgrammingLanguage", fields: %{"name" => "Elixir"}, rid: _, version: _}

      > ExOrient.DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"}, return: "@rid")
      [9, 224]

  """
  def insert(opts) do
    into =
      opts
      |> Keyword.get(:into)
      |> QB.class_name()

    query = "INSERT INTO #{into}"

    {query, params} =
      opts
      |> Keyword.get(:values)
      |> QB.append_values(query, %{})

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
      |> Keyword.get(:return)
      |> QB.append_return(query, params)

    {query, params} =
      opts
      |> Keyword.get(:from)
      |> QB.append_from(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Perform an update command. Examples:

      > ExOrient.DB.update("#9:568", set: [name: "C"])
      1

      > ExOrient.DB.update(ProgrammingLanguage, where: %{name: "C"}, merge: %{type: ["Old", "Fast"]}, return: :after)
      [%MarcoPolo.Document{class: "ProgrammingLanguage", fields: %{"name" => "C", "type" => ["Old", "Fast"]}, _, version: _}, ...]

      > ExOrient.DB.update("#9:568", remove: [type: "Old"])
      1

      > ExOrient.DB.update(Person, set: [name: "Bob"], where: %{name: "Bob"}, upsert: true, return: :after)
      [%MarcoPolo.Document{class: "Person", fields: %{"name" => "Bob"}, rid: _, version: _}]

  """
  def update(obj, opts \\ [])
  def update(%MarcoPolo.RID{cluster_id: cid, position: pos}, opts), do: update("##{cid}:#{pos}", opts)
  def update(class, opts) do
    class = QB.class_name(class)

    query = "UPDATE #{class}"

    {query, params} =
      opts
      |> Keyword.get(:set)
      |> QB.append_set(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:increment)
      |> QB.append_increment(query, params)

    {query, params} =
      opts
      |> Keyword.get(:add)
      |> QB.append_add(query, params)

    {query, params} =
      opts
      |> Keyword.get(:remove)
      |> QB.append_remove(query, params)

    {query, params} =
      opts
      |> Keyword.get(:put)
      |> QB.append_put(query, params)

    {query, params} =
      opts
      |> Keyword.get(:content)
      |> QB.append_content(query, params)

    {query, params} =
      opts
      |> Keyword.get(:merge)
      |> QB.append_merge(query, params)

    {query, params} =
      opts
      |> Keyword.get(:upsert)
      |> QB.append_upsert(query, params)

    {query, params} =
      opts
      |> Keyword.get(:return)
      |> QB.append_return(query, params)

    {query, params} =
      opts
      |> Keyword.get(:where)
      |> QB.append_where(query, params)

    {query, params} =
      opts
      |> Keyword.get(:lock)
      |> QB.append_lock(query, params)

    {query, params} =
      opts
      |> Keyword.get(:limit)
      |> QB.append_limit(query, params)

    {query, params} =
      opts
      |> Keyword.get(:timeout)
      |> QB.append_timeout(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Run a delete command. Examples:

      >
  """
  def delete(opts \\ []) do
    from =
      opts
      |> Keyword.get(:from)
      |> QB.class_name()

    query = "DELETE FROM #{from}"

    {query, params} =
      opts
      |> Keyword.get(:lock)
      |> QB.append_lock(query, %{})

    {query, params} =
      opts
      |> Keyword.get(:return)
      |> QB.append_return(query, params)

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
      |> Keyword.get(:timeout)
      |> QB.append_timeout(query, params)

    DB.command(query, params: params)
  end

  @doc """
  Passes a truncate command off to the correct function
  """
  def truncate(opts \\ []) do
    cond do
      Keyword.get(opts, :class) -> truncate_class(opts)
      Keyword.get(opts, :cluster) -> truncate_cluster(opts)
      Keyword.get(opts, :record) -> truncate_record(opts)
      true -> {:error, "Invalid command"}
    end
  end

  @doc """
  Truncate a class

      > ExOrient.DB.truncate(class: Person)

  """
  def truncate_class(opts \\ []) do
    name = Keyword.get(opts, :class) |> QB.class_name()
    query = "TRUNCATE CLASS #{name}"

    {query, params} =
      opts
      |> Keyword.get(:polymorphic)
      |> QB.append_polymorphic(query, %{})

    {query, _params} =
      opts
      |> Keyword.get(:unsafe)
      |> QB.append_unsafe(query, params)

    DB.command(query)
  end

  @doc """
  Truncate a cluster

      > ExOrient.DB.truncate(cluster: "Germany")

  """
  def truncate_cluster(opts \\ []) do
    name = Keyword.get(opts, :cluster)
    query = "TRUNCATE CLUSTER #{name}"
    DB.command(query)
  end

  @doc """
  Truncate a record

      > ExOrient.DB.truncate(record: "#11:2")

      > ExOrient.DB.truncate(record: ["#11:2", "#11:3"])

  """
  def truncate_record(opts \\ []) do
    rids =
      opts
      |> Keyword.get(:record)
      |> QB.to_list()
      |> Enum.map(&QB.class_name/1)
      |> Enum.join(", ")
      |> QB.wrap_in_square_brackets()

    query = "TRUNCATE RECORD #{rids}"
    DB.command(query)
  end
end
