defmodule ExOrient.DB.CRUDTest do
  use ExUnit.Case
  alias MarcoPolo.Document
  alias ExOrient.DB

  setup_all do
    DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
    DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir", type: "Awesome"})
    DB.insert(into: ProgrammingLanguage, content: %{name: "C", type: "Fast"})
    DB.insert(into: ProgrammingLanguage, content: %{name: "LOLCODE", type: "Humor"})
    DB.insert(into: ProgrammingLanguage, content: %{name: "this_is_more_than_ten"})

    on_exit(fn ->
      DB.delete(from: ProgrammingLanguage)
    end)
    :ok
  end

  @tag :db
  test "insert with values syntax" do
    doc = DB.insert(into: ProgrammingLanguage, values: {[:name, :type], ["Elixir", "Awesome"]})
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "Elixir", "type" => "Awesome"}
    } = doc
  end

  @tag :db
  test "insert with set syntax" do
    doc = DB.insert(into: ProgrammingLanguage, set: [name: "Elixir", type: "Awesome"])
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "Elixir", "type" => "Awesome"}
    } = doc
  end

  @tag :db
  test "insert with content syntax" do
    doc = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir", meta: %{emotion: "Fun", type: "Awesome"}})
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "Elixir", "meta" => %{"emotion" => "Fun", "type" => "Awesome"}}
    } = doc
  end

  @tag :db
  test "basic select" do
    docs = DB.select(from: ProgrammingLanguage)
    assert is_list(docs) and length(docs) > 0
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => _}
    } = hd(docs)
  end

  @tag :db
  test "select with fields" do
    docs = DB.select([:name], from: ProgrammingLanguage)
    assert is_list(docs) and length(docs) > 0
    assert %Document{
      class: _,
      rid: _,
      version: _,
      fields: %{"name" => _}
    } = hd(docs)
  end

  @tag :db
  test "select with simple where clause" do
    [elixir | _] = DB.select(from: ProgrammingLanguage, where: %{name: "Elixir"})
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "Elixir"}
    } = elixir
  end

  @tag :db
  test "select with two element where clause" do
    [elixir | _] = DB.select(from: ProgrammingLanguage, where: %{name: "Elixir", type: "Awesome"})
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "Elixir", "type" => "Awesome"}
    } = elixir
  end

  @tag :db
  test "select with logical or" do
    [doc | _] = DB.select(from: ProgrammingLanguage, where: %{name: "Elixir", type: "Awesome"}, logical: "OR")
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: _
    } = doc
  end

  @tag :db
  test "select using a class method" do
    [lolcode | _] = DB.select(from: ProgrammingLanguage, where: %{"name.toLowerCase()" => "lolcode"})
    assert %Document{
      class: "ProgrammingLanguage",
      rid: _,
      version: _,
      fields: %{"name" => "LOLCODE"}
    } = lolcode
  end

  @tag :db
  test "select using a class method and custom operator" do
    [doc | _] = DB.select(from: ProgrammingLanguage, where: {"name.length()", ">", 10})
    assert doc.fields["name"] > 10
  end

  @tag :db
  test "select using class methods, custom operators, and a logical or" do
    [doc | _] = DB.select(from: ProgrammingLanguage,
                     where: [{"name.length()", ">", 10},
                             {"name.left(2)", "=", "El"}],
                     logical: "OR")
    assert doc.fields["name"] > 10 or String.starts_with?(doc.fields["name"], "El")
  end

  @tag :db
  test "select by rid using shortcut" do
    [doc | _] = DB.select(from: ProgrammingLanguage)
    same_doc = DB.rid(doc.rid)
    assert doc == same_doc
  end

  @tag :db
  test "use a group by statement" do
    names = DB.select(from: ProgrammingLanguage, group_by: :name)
    |> Enum.map(fn(doc) -> doc.fields["name"] end)

    assert names == Enum.dedup(names)
  end

  @tag :db
  test "use a let block" do
    elixir = DB.select(from: ProgrammingLanguage, let: %{"$n" => :name}, where: %{"$n" => "Elixir"})
      |> Enum.map(fn(doc) -> doc.fields["name"] end)
      |> Enum.dedup()
    assert length(elixir) == 1
    assert elixir == ["Elixir"]
  end

  @tag :db
  test "order by something" do
    names = DB.select(from: ProgrammingLanguage, order_by: :name)
      |> Enum.map(fn(doc) -> doc.fields["name"] end)
      |> Enum.dedup()

    assert Enum.at(names, 0) == Enum.sort(names) |> Enum.at(0)
  end

  @tag :db
  test "unwind" do
    assert DB.select(from: ProgrammingLanguage, unwind: :name) |> length() > 0
  end

  @tag :db
  test "skip" do
    [first | _] = DB.select(from: ProgrammingLanguage)
    [second | _] = DB.select(from: ProgrammingLanguage, skip: 1)
    assert first.rid != second.rid
  end

  @tag :db
  test "limit" do
    assert 1 == DB.select(from: ProgrammingLanguage, limit: 1) |> length()
  end

  @tag :db
  test "update rid with set" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, set: [name: "Update"])
    updated = DB.update(rid, set: [name: "Updated"])
    assert updated == 1
  end

  @tag :db
  test "update rid with increment" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, set: [number: 0])
    updated = DB.update(rid, increment: [number: 5])
    assert updated == 1
  end

  @tag :db
  test "update rid with add" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
    updated = DB.update(rid, add: [type: "Awesome"])
    assert updated == 1
  end

  @tag :db
  test "update with remove" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir", number: 0})
    updated = DB.update(rid, remove: :number)
    assert updated == 1
  end

  @tag :db
  test "update with put" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
    updated = DB.update(rid, put: [meta: {"type", "awesome"}])
    assert updated == 1
  end

  @tag :db
  test "update with content" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
    updated = DB.update(rid, content: %{name: "C", type: "Old"})
    assert updated == 1
  end

  @tag :db
  test "update with merge" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Elixir"})
    updated = DB.update(rid, merge: %{type: "Awesome"})
    assert updated == 1
  end

  @tag :db
  test "upsert and where" do
    DB.insert(into: ProgrammingLanguage, content: %{name: "upsert-test"})
    updated = DB.update(ProgrammingLanguage, set: [name: "upsert-testing"], upsert: true, where: %{name: "upsert-test"})
    assert updated > 0
  end

  @tag :db
  test "update limit" do
    count = DB.update(ProgrammingLanguage, set: [name: "Elixir"], where: %{name: "Elixir"}, limit: 1)
    assert count <= 1
  end

  @tag :db
  test "delete by rid" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "Erlang"})
    count = DB.delete(from: rid)
    assert count == 1
  end

  @tag :db
  test "delete with where" do
    DB.insert(into: ProgrammingLanguage, content: %{name: "JavaScript"})
    count = DB.delete(from: ProgrammingLanguage, where: %{name: "JavaScript"})
    assert count > 0
  end

  @tag :db
  test "truncate class" do
    DB.create(class: TruncateTest)
    assert nil != DB.truncate(class: TruncateTest)
    DB.drop(class: TruncateTest)
  end

  @tag :db
  test "truncate cluster" do
    DB.command("CREATE CLUSTER Germany")
    assert nil != DB.truncate(cluster: "Germany")
    DB.command("DROP CLUSTER Germany")
  end

  @tag :db
  test "truncate record" do
    %Document{rid: rid} = DB.insert(into: ProgrammingLanguage, content: %{name: "JavaScript"})
    assert nil != DB.truncate(record: rid)
    DB.delete(from: rid)
  end
end
