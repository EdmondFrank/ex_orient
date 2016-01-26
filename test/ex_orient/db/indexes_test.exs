defmodule ExOrient.DB.IndexesTest do
  use ExUnit.Case
  alias ExOrient.DB

  setup do
    DB.create(class: IndexesTest)
    DB.create(property: "IndexesTest.name", type: :string)
    on_exit(fn ->
      DB.drop(class: IndexesTest)
    end)
  end

  @tag :db
  test "create an index" do
    DB.create(index: "name", on: "IndexesTest (name)", index_type: :unique, key_type: :string)
    DB.drop(index: "name")
  end

  @tag :db
  test "rebuild an index" do
    DB.create(index: "name", on: "IndexesTest (name)", index_type: :unique, key_type: :string)
    DB.rebuild(index: "name")
    DB.drop(index: "name")
  end

  @tag :db
  test "drop an index" do
    DB.drop(index: "name")
  end
end
