defmodule ExOrient.QueryBuilderTest do
  use ExUnit.Case, async: true
  alias ExOrient.QueryBuilder

  doctest QueryBuilder

  test "get correct class names" do
    assert "Person" == QueryBuilder.class_name(Models.Person)
    assert "Person" == QueryBuilder.class_name("Person")
  end

  test "wrap in parentheses" do
    assert "(name)" == QueryBuilder.wrap_in_parens("name")
  end

  test "wrap in square brackets" do
    assert "[name]" == QueryBuilder.wrap_in_square_brackets("name")
  end

  test "convert to list" do
    assert [:a] == QueryBuilder.to_list(:a)
    assert [:a] == QueryBuilder.to_list([:a])
  end

  test "append let" do
    assert {"SELECT FROM Test LET $n = name", _} = QueryBuilder.append_let(%{"$n" => :name}, "SELECT FROM Test", %{})
  end

  test "append where" do
    {query, _} = QueryBuilder.append_where(%{name: "Elixir", type: "Awesome"}, "SELECT FROM Test", %{})
    assert query =~ "SELECT FROM Test"
    assert query =~ "WHERE"
    assert query =~ "name"
    assert query =~ "AND"
    assert query =~ "type"
  end

  test "append group by" do
    assert {"SELECT FROM Test GROUP BY name", _} = QueryBuilder.append_group_by(:name, "SELECT FROM Test", %{})
  end

  test "append order by" do
    assert {"SELECT FROM Test ORDER BY name, type ASC", _} = QueryBuilder.append_order_by([:name, :type], "SELECT FROM Test", %{})
  end

  test "append unwind" do
    assert {"SELECT FROM People UNWIND name", _} = QueryBuilder.append_unwind(:name, "SELECT FROM People", %{})
  end

  test "append skip" do
    assert {"SELECT FROM Test SKIP 20", _} = QueryBuilder.append_skip(20, "SELECT FROM Test", %{})
  end

  test "append limit" do
    assert {"SELECT FROM Test LIMIT 5", _} = QueryBuilder.append_limit(5, "SELECT FROM Test", %{})
  end

  test "append fetchplan" do
    assert {"SELECT FROM Test FETCHPLAN *:-1", _} = QueryBuilder.append_fetchplan("*:-1", "SELECT FROM Test", %{})
  end

  test "append timeout" do
    assert {"SELECT FROM Test TIMEOUT 5000", _} = QueryBuilder.append_timeout(5000, "SELECT FROM Test", %{})
    assert {"SELECT FROM Test TIMEOUT 5000 RETURN", _} = QueryBuilder.append_timeout({5000, :return}, "SELECT FROM Test", %{})
    assert {"SELECT FROM Test TIMEOUT 5000 EXCEPTION", _} = QueryBuilder.append_timeout({5000, :exception}, "SELECT FROM Test", %{})
  end

  test "append lock" do
    assert {"SELECT FROM Test LOCK DEFAULT", _} = QueryBuilder.append_lock(:default, "SELECT FROM Test", %{})
    assert {"SELECT FROM Test LOCK RECORD", _} = QueryBuilder.append_lock(:record, "SELECT FROM Test", %{})
  end

  test "append parallel" do
    assert {"SELECT FROM Test PARALLEL", _} = QueryBuilder.append_parallel(true, "SELECT FROM Test", %{})
    assert {"SELECT FROM Test", _} = QueryBuilder.append_parallel(false, "SELECT FROM Test", %{})
  end

  test "append nocache" do
    assert {"SELECT FROM Test NOCACHE", _} = QueryBuilder.append_nocache(true, "SELECT FROM Test", %{})
    assert {"SELECT FROM Test", _} = QueryBuilder.append_nocache(false, "SELECT FROM Test", %{})
  end

  test "append values" do
    assert {"INSERT INTO Test (foo, bar) VALUES (:values_foo, :values_bar)", %{"values_foo" => "hello", "values_bar" => "world"}} =
            QueryBuilder.append_values({[:foo, :bar], ["hello", "world"]}, "INSERT INTO Test", %{})
  end

  test "append set" do
    assert {"INSERT INTO Test SET foo = :set_foo, bar = :set_bar", %{"set_foo" => "hello", "set_bar" => "world"}} =
            QueryBuilder.append_set([foo: "hello", bar: "world"], "INSERT INTO Test", %{})
  end

  test "append content" do
    assert {"INSERT INTO Test CONTENT {\"foo\":\"hello\",\"bar\":\"world\"}", %{}} =
            QueryBuilder.append_content(%{foo: "hello", bar: "world"}, "INSERT INTO Test", %{})
  end

  test "append return" do
    assert {"INSERT INTO Test RETURN @rid", %{}} = QueryBuilder.append_return("@rid", "INSERT INTO Test", %{})
  end

  test "append from" do
    assert {"INSERT INTO Test FROM (SELECT FROM Test)", %{}} = QueryBuilder.append_from("(SELECT FROM Test)", "INSERT INTO Test", %{})
  end

  test "append increment" do
    assert {"UPDATE Counter INCREMENT views = :increment_views", %{"increment_views" => 1}} =
            QueryBuilder.append_increment([views: 1], "UPDATE Counter", %{})
  end

  test "append add" do
    assert {"UPDATE Account ADD address = :add_address", %{"add_address" => "#12:0"}} =
            QueryBuilder.append_add([address: "#12:0"], "UPDATE Account", %{})
  end

  test "append remove" do
    assert {"UPDATE Person REMOVE email", %{}} = QueryBuilder.append_remove(:email, "UPDATE Person", %{})
  end

  test "append put" do
    assert {"UPDATE Person PUT addresses = :put_addresses_key, :put_addresses_val", %{"put_addresses_key" => "CLE", "put_addresses_val" => "#12:0"}} =
          QueryBuilder.append_put([addresses: {"CLE", "#12:0"}], "UPDATE Person", %{})
  end

  test "append merge" do
    assert {"UPDATE Person MERGE {\"key\":\"val\"}", %{}} = QueryBuilder.append_merge(%{key: "val"}, "UPDATE Person", %{})
  end

  test "append upsert" do
    assert {"UPDATE Test UPSERT", %{}} = QueryBuilder.append_upsert(true, "UPDATE Test", %{})
  end

  test "append cluster" do
    assert {"CREATE VERTEX V1 CLUSTER Germany", %{}} = QueryBuilder.append_cluster("Germany", "CREATE VERTEX V1", %{})
  end

  test "append from edge" do
    assert {"CREATE EDGE Watched FROM #10:0", %{}} = QueryBuilder.append_from("#10:0", "CREATE EDGE Watched", %{})
  end

  test "append to" do
    assert {"CREATE EDGE Test TO #10:0", %{}} = QueryBuilder.append_to("#10:0", "CREATE EDGE Test", %{})
  end

  test "append retry" do
    assert {"CREATE EDGE Test RETRY 5", %{}} = QueryBuilder.append_retry(5, "CREATE EDGE Test", %{})
  end

  test "append wait" do
    assert {"CREATE EDGE Test WAIT 500", %{}} = QueryBuilder.append_wait(500, "CREATE EDGE Test", %{})
  end

  test "append batch" do
    assert {"CREATE EDGE Test BATCH 50", %{}} = QueryBuilder.append_batch(50, "CREATE EDGE Test", %{})
  end

  test "append vertex" do
    assert {"DELETE VERTEX Test", %{}} = QueryBuilder.append_vertex("Test", "DELETE", %{})
  end

  test "append edge" do
    assert {"DELETE EDGE Test", %{}} = QueryBuilder.append_edge("Test", "DELETE", %{})
  end

  test "append extends" do
    assert {"CREATE CLASS Person EXTENDS E", %{}} = QueryBuilder.append_extends("E", "CREATE CLASS Person", %{})
  end

  test "append abstract" do
    assert {"CREATE CLASS Person ABSTRACT", %{}} = QueryBuilder.append_abstract(true, "CREATE CLASS Person", %{})
  end

  test "append on" do
    assert {"CREATE INDEX name ON Person (name)", %{}} = QueryBuilder.append_on("Person (name)", "CREATE INDEX name", %{})
  end

  test "append type" do
    assert {"CREATE INDEX Test UNIQUE", %{}} = QueryBuilder.append_type(:unique, "CREATE INDEX Test", %{})
  end

  test "append metadata" do
    assert {"CREATE INDEX Test METADATA {\"ignoreNullValues\":false}", %{}} =
            QueryBuilder.append_metadata(%{ignoreNullValues: false}, "CREATE INDEX Test", %{})
  end

  test "append unsafe" do
    assert {"TRUNCATE CLASS Test UNSAFE", %{}} = QueryBuilder.append_unsafe(true, "TRUNCATE CLASS Test", %{})
  end

  test "append polymorphic" do
    assert {"TRUNCATE CLASS Test POLYMORPHIC", %{}} = QueryBuilder.append_polymorphic(true, "TRUNCATE CLASS Test", %{})
  end

  test "append force" do
    assert {"DROP PROPERTY Test.name FORCE", %{}} = QueryBuilder.append_force(true, "DROP PROPERTY Test.name", %{})
  end
end
