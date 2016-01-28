defmodule ExOrient.DB.IndexesTest do
  use ExUnit.Case
  alias ExOrient.DB

  test "create an index" do
    {query, _} = DB.create(index: "name", on: "IndexesTest (name)", index_type: :unique, key_type: :string)
    assert query == "CREATE INDEX name ON IndexesTest (name) UNIQUE STRING"
  end

  test "rebuild an index" do
    {query, _} = DB.rebuild(index: "name")
    assert query == "REBUILD INDEX name"
  end

  test "drop an index" do
    {query, _} = DB.drop(index: "name")
    assert query == "DROP INDEX name"
  end
end
