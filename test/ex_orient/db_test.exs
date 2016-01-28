defmodule ExOrient.DBTest do
  @moduledoc """
  Integration tests that actually query the database and require a valid connection.
  """

  use ExUnit.Case
  alias ExOrient.DB

  @tag :db
  test "create a graph" do
    DB.create(class: "ExOrientDBTest", extends: "V") |> DB.exec()
    DB.create(class: "ExOrientDBTest2", extends: "V") |> DB.exec()
    DB.create(class: "exorient_member_of", extends: "E") |> DB.exec()

    DB.insert(into: "ExOrientDBTest", set: [name: "test"]) |> DB.exec()
    DB.insert(into: "ExOrientDBTest2", set: [name: "hello"]) |> DB.exec()
    DB.insert(into: "ExOrientDBTest2", set: [name: "world"]) |> DB.exec()

    from = DB.select(from: "ExOrientDBTest2", where: [name: "hello", name: "world"], logical: :or)
    to = DB.select(from: "ExOrientDBTest", where: [name: "test"])
    DB.create(edge: "exorient_member_of", from: from, to: to) |> DB.exec()

    {:ok, docs} = DB.select(["expand(in('exorient_member_of'))"], from: "ExOrientDBTest") |> DB.exec()
    assert length(docs) == 2

    first = hd(docs)
    assert first.fields["name"] == "hello" || first.fields["name"] == "world"

    DB.drop(class: "ExOrientDBTest", unsafe: true) |> DB.exec()
    DB.drop(class: "ExOrientDBTest2", unsafe: true) |> DB.exec()
    DB.drop(class: "exorient_member_of", unsafe: true) |> DB.exec()
  end
end
