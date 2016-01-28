defmodule ExOrient.DB.CRUDTest do
  use ExUnit.Case
  alias ExOrient.DB

  test "insert with values syntax" do
    expected = {"INSERT INTO Test (name, type) VALUES (:values_name, :values_type)", %{"values_name" => "Elixir", "values_type" => "Awesome"}}
    actual = DB.insert(into: Test, values: {[:name, :type], ["Elixir", "Awesome"]})
    assert expected == actual
  end

  test "insert with set syntax" do
    expected = {"INSERT INTO Test SET name = :set_name, type = :set_type", %{"set_name" => "Elixir", "set_type" => "Awesome"}}
    actual = DB.insert(into: Test, set: [name: "Elixir", type: "Awesome"])
    assert expected == actual
  end

  test "insert with content syntax" do
    expected = {"INSERT INTO Test CONTENT {\"name\":\"Elixir\",\"meta\":{\"type\":\"Awesome\",\"emotion\":\"Fun\"}}", %{}}
    actual = DB.insert(into: Test, content: %{name: "Elixir", meta: %{emotion: "Fun", type: "Awesome"}})
    assert expected == actual
  end

  test "basic select" do
    expected = {"SELECT FROM Test", %{}}
    actual = DB.select(from: Test)
    assert expected == actual
  end

  test "select with fields" do
    expected = {"SELECT name FROM Test", %{}}
    actual = DB.select([:name], from: Test)
    assert expected == actual
  end

  test "select with simple where clause" do
    actual = DB.select(from: Test, where: %{name: "Elixir"})
    assert {"SELECT FROM Test WHERE name = :" <> _, %{}} = actual
  end

  test "select with two element where clause" do
    {query, params} = DB.select(from: Test, where: %{name: "Elixir", type: "Awesome"})
    assert query =~ "SELECT"
    assert query =~ "WHERE"
    assert query =~ "AND"
    assert is_map(params)
  end

  test "select with logical or" do
    {query, params} = DB.select(from: Test, where: %{name: "Elixir", type: "Awesome"}, logical: "OR")
    assert query =~ "SELECT"
    assert query =~ "WHERE"
    assert query =~ "OR"
    assert is_map(params)
  end

  test "select using a class method" do
    {query, params} = DB.select(from: Test, where: %{"name.toLowerCase()" => "lolcode"})
    assert query =~ "SELECT"
    assert query =~ "WHERE"
    assert query =~ "name.toLowerCase()"
    assert is_map(params)
  end

  test "select using a class method and custom operator" do
    {query, _} = DB.select(from: Test, where: {"name.length()", ">", 10})
    assert query =~ "SELECT"
    assert query =~ "WHERE"
    assert query =~ "name.length()"
    assert query =~ ">"
  end

  test "select using class methods, custom operators, and a logical or" do
    {query, _} = DB.select(from: Test,
                     where: [{"name.length()", ">", 10},
                             {"name.left(2)", "=", "El"}],
                     logical: "OR")
    assert query =~ "SELECT"
    assert query =~ "name.length()"
    assert query =~ ">"
    assert query =~ "name.left(2)"
    assert query =~ "="
    assert query =~ "OR"
  end

  test "select by rid using shortcut" do
    {query, _} = DB.rid("#11:7")
    assert query == "SELECT FROM #11:7"
  end

  test "use a group by statement" do
    {query, _} = DB.select(from: Test, group_by: :name)
    assert query == "SELECT FROM Test GROUP BY name"
  end

  test "use a let block" do
    {query, _} = DB.select(from: Test, let: %{"$n" => :name}, where: %{"$n" => "Elixir"})
    assert query =~ "SELECT"
    assert query =~ "LET"
    assert query =~ "$n"
    assert query =~ "="
    assert query =~ "name"
    assert query =~ "WHERE"
  end

  test "order by something" do
    {query, _} = DB.select(from: Test, order_by: :name)
    assert query =~ "SELECT"
    assert query =~ "ORDER BY"
    assert query =~ "name"
  end

  test "unwind" do
    {query, _} = DB.select(from: Test, unwind: :name)
    assert query =~ "SELECT"
    assert query =~ "UNWIND"
    assert query =~ "name"
  end

  test "skip" do
    {query, _} = DB.select(from: Test, skip: 1)
    assert query =~ "SELECT"
    assert query =~ "SKIP"
    assert query =~ "1"
  end

  test "limit" do
     {query, _} = DB.select(from: Test, limit: 1)
     assert query =~ "SELECT"
     assert query =~ "LIMIT"
     assert query =~ "1"
  end

  test "update rid with set" do
    {query, _} = DB.update("#11:7", set: [name: "Updated"])
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "SET"
  end

  test "update rid with increment" do
    {query, _} = DB.update("#11:7", increment: [number: 5])
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "INCREMENT"
    assert query =~ "number"
  end

  test "update rid with add" do
    {query, _} = DB.update("#11:7", add: [type: "Awesome"])
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "ADD"
    assert query =~ "type"
  end

  test "update with remove" do
    {query, _} = DB.update("#11:7", remove: :number)
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "REMOVE"
    assert query =~ "number"
  end

  test "update with put" do
    {query, _} = DB.update("#11:7", put: [meta: {"type", "awesome"}])
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "PUT"
    assert query =~ "meta"
  end

  test "update with content" do
    {query, _} = DB.update("#11:7", content: %{name: "C", type: "Old"})
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "CONTENT"
    assert query =~ "name"
    assert query =~ "C"
    assert query =~ "type"
    assert query =~ "Old"
  end

  test "update with merge" do
    {query, _} = DB.update("#11:7", merge: %{type: "Awesome"})
    assert query =~ "UPDATE"
    assert query =~ "#11:7"
    assert query =~ "MERGE"
    assert query =~ "type"
    assert query =~ "Awesome"
  end

  test "upsert and where" do
    {query, _} = DB.update(Test, set: [name: "upsert-testing"], upsert: true, where: %{name: "upsert-test"})
    assert query =~ "UPDATE"
    assert query =~ "SET"
    assert query =~ "UPSERT"
    assert query =~ "WHERE"
  end

  test "update limit" do
    {query, _} = DB.update(Test, set: [name: "Something"], where: %{name: "Elixir"}, limit: 1)
    assert query =~ "UPDATE"
    assert query =~ "Test"
    assert query =~ "SET"
    assert query =~ "WHERE"
    assert query =~ "LIMIT"
    assert query =~ "1"
  end

  test "delete by rid" do
    {query, _} = DB.delete(from: "#11:7")
    assert query == "DELETE FROM #11:7"
  end

  test "delete with where" do
    {query, _} = DB.delete(from: Test, where: %{name: "JavaScript"})
    assert query =~ "DELETE"
    assert query =~ "FROM"
    assert query =~ "Test"
    assert query =~ "WHERE"
  end

  test "truncate class" do
    {query, _} = DB.truncate(class: Test)
    assert query == "TRUNCATE CLASS Test"
  end

  test "truncate cluster" do
    {query, _} = DB.truncate(cluster: "East")
    assert query == "TRUNCATE CLUSTER East"
  end

  test "truncate record" do
    {query, _} = DB.truncate(record: "#11:7")
    assert query == "TRUNCATE RECORD [#11:7]"
  end
end
