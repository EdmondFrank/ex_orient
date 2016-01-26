defmodule ExOrient.DB.SchemaTest do
  use ExUnit.Case

  alias ExOrient.DB

  @tag :db
  test "create class" do
    assert 0 < DB.create(class: SchemaTestClass, extends: "E", abstract: true)
    DB.drop(class: SchemaTestClass)
  end

  @tag :db
  test "alter class" do
    DB.create(class: SchemaTestClass, extends: "E")
    assert nil == DB.alter(class: SchemaTestClass, attr: "SUPERCLASS -E")
    DB.drop(class: SchemaTestClass)
  end

  @tag :db
  test "drop class" do
    DB.create(class: SchemaTestClass, extends: "E")
    assert true == DB.drop(class: SchemaTestClass)
  end

  @tag :db
  test "create property" do
    DB.create(class: SchemaTestClass, extends: "E")
    assert 1 == DB.create(property: "SchemaTestClass.name", type: :string, unsafe: true)
    DB.drop(property: "SchemaTestClass.name")
    DB.drop(class: SchemaTestClass)
  end

  @tag :db
  test "alter property" do
    DB.create(class: SchemaTestClass, extends: "E")
    DB.create(property: "SchemaTestClass.name", type: :string)
    assert nil == DB.alter(property: "SchemaTestClass.name", attr: "REGEXP [M|F]")
    DB.drop(property: "SchemaTestClass.name")
    DB.drop(class: SchemaTestClass)
  end

  @tag :db
  test "drop property" do
    DB.create(class: SchemaTestClass, extends: "E")
    DB.create(property: "SchemaTestClass.name", type: :string)
    assert nil == DB.drop(property: "SchemaTestClass.name")
    DB.drop(class: SchemaTestClass)
  end
end
