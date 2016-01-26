defmodule ExOrient.DB.GraphTest do
  use ExUnit.Case
  alias MarcoPolo.Document
  alias ExOrient.DB

  @tag :db
  test "create a vertex" do
    assert %Document{class: "V", fields: %{"message" => "hello"}} = DB.create(vertex: "V", content: %{message: "hello"})
  end

  @tag :db
  test "create an edge" do
    a = DB.create(vertex: "V")
    b = DB.create(vertex: "V")
    assert [%Document{class: "E", fields: %{"in" => _, "out" => _}}] = DB.create(edge: "E", from: a.rid, to: b.rid)
  end

  @tag :db
  test "delete a vertex" do
    a = DB.create(vertex: "V")
    assert 1 == DB.delete(vertex: a.rid)
  end

  @tag :db
  test "delete an edge" do
    a = DB.create(vertex: "V")
    b = DB.create(vertex: "V")
    [edge] = DB.create(edge: "E", from: a.rid, to: b.rid)
    assert 1 == DB.delete(edge: edge.rid)
  end
end
