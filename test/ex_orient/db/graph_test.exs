defmodule ExOrient.DB.GraphTest do
  use ExUnit.Case
  alias ExOrient.DB

  test "create a vertex" do
    {query, _} = DB.create(vertex: "V", content: %{message: "hello"})
    assert query == "CREATE VERTEX V CONTENT {\"message\":\"hello\"}"
  end

  test "create an edge" do
    {query, _} = DB.create(edge: "E", from: "#11:7", to: "#11:8")
    assert query == "CREATE EDGE E FROM #11:7 TO #11:8"
  end

  test "delete a vertex" do
    {query, _} = DB.delete(vertex: "#11:7")
    assert query == "DELETE VERTEX #11:7"
  end

  test "delete an edge" do
    {query, _} = DB.delete(edge: "#11:7")
    assert query == "DELETE EDGE #11:7"
  end
end
