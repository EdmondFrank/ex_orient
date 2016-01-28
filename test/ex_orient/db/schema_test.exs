defmodule ExOrient.DB.SchemaTest do
  use ExUnit.Case
  alias ExOrient.DB

  test "create class" do
    {query, _} = DB.create(class: Test, extends: "E", abstract: true)
    assert query == "CREATE CLASS Test EXTENDS E ABSTRACT"
  end

  test "alter class" do
    {query, _} = DB.alter(class: Test, attr: "SUPERCLASS -E")
    assert query == "ALTER CLASS Test SUPERCLASS -E"
  end

  test "drop class" do
    {query, _} = DB.drop(class: Test)
    assert query == "DROP CLASS Test"
  end

  test "create property" do
    {query, _} = DB.create(property: "Test.name", type: :string, unsafe: true)
    assert query == "CREATE PROPERTY Test.name STRING UNSAFE"
  end

  test "alter property" do
    {query, _} = DB.alter(property: "Test.name", attr: "REGEXP [M|F]")
    assert query == "ALTER PROPERTY Test.name REGEXP [M|F]"
  end

  test "drop property" do
    {query, _} = DB.drop(property: "Test.name")
    assert query == "DROP PROPERTY Test.name"
  end
end
