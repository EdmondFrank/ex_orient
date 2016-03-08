defmodule ExOrient.FunctionsTest do
  use ExUnit.Case
  import ExOrient.Functions

  doctest ExOrient.Functions

  test "out" do
    assert out() == "out()"
    assert out("Eats") == "out('Eats')"
    assert out(["Eats", "Favorited"]) == "out('Eats', 'Favorited')"
  end

  test "in" do
    assert o_in() == "in()"
    assert o_in("Eats") == "in('Eats')"
    assert o_in(["Eats", "Favorited"]) == "in('Eats', 'Favorited')"
  end

  test "both" do
    assert both() == "both()"
    assert both("Eats") == "both('Eats')"
    assert both(["Eats", "Favorited"]) == "both('Eats', 'Favorited')"
  end

  test "outE" do
    assert out_e() == "outE()"
    assert out_e("Eats") == "outE('Eats')"
    assert out_e(["Eats", "Favorited"]) == "outE('Eats', 'Favorited')"
  end

  test "inE" do
    assert in_e() == "inE()"
    assert in_e("Eats") == "inE('Eats')"
    assert in_e(["Eats", "Favorited"]) == "inE('Eats', 'Favorited')"
  end

  test "bothE" do
    assert both_e() == "bothE()"
    assert both_e("Eats") == "bothE('Eats')"
    assert both_e(["Eats", "Favorited"]) == "bothE('Eats', 'Favorited')"
  end

  test "outV" do
    assert out_v() == "outV()"
  end

  test "inV" do
    assert in_v() == "inV()"
  end

  test "eval" do
    assert eval("price * 120 / 100 - discount") == "eval('price * 120 / 100 - discount')"
  end

  test "coalesce" do
    assert coalesce(:amount) == "coalesce(amount)"
    assert coalesce("amount") == "coalesce(amount)"
    assert coalesce([:amount, :amount1]) == "coalesce(amount, amount1)"
  end

  test "if" do
    assert o_if("true", "Hello", "Goodbye") == "if('true', 'Hello', 'Goodbye')"
  end

  test "expand" do
    assert expand(:addresses) == "expand(addresses)"
    assert expand("addresses") == "expand(addresses)"
    assert expand(out(Friended)) == "expand(out('Friended'))"
    assert expand(out("Friended")) == "expand(out('Friended'))"
  end

  test "first" do
    assert first(:addresses) == "first(addresses)"
    assert first("addresses") == "first(addresses)"
  end

  test "last" do
    assert last(:addresses) == "last(addresses)"
    assert last("addresses") == "last(addresses)"
  end

  test "count" do
    assert count("*") == "COUNT(*)"
    assert count(:address) == "COUNT(address)"
  end

  test "min" do
    assert o_min(:salary) == "min(salary)"
    assert o_min("salary") == "min(salary)"
    assert o_min([:salary, :salary2]) == "min(salary, salary2)"
  end

  test "max" do
    assert o_max(:salary) == "max(salary)"
    assert o_max("salary") == "max(salary)"
    assert o_max([:salary, :salary2]) == "max(salary, salary2)"
  end

  test "abs" do
    assert o_abs(:score) == "abs(score)"
    assert o_abs("score") == "abs(score)"
    assert o_abs(-999) == "abs(-999)"
  end

  test "avg" do
    assert avg(:salary) == "avg(salary)"
    assert avg("salary") == "avg(salary)"
  end

  test "sum" do
    assert sum(:salary) == "sum(salary)"
    assert sum("salary") == "sum(salary)"
  end

  test "date" do
    assert date("2012-07-02", "yyyy-MM-dd", "UTC") == "date('2012-07-02', 'yyyy-MM-dd', 'UTC')"
    assert date("2012-07-02", "yyyy-MM-dd") == "date('2012-07-02', 'yyyy-MM-dd')"
    assert date("2012-07-02") == "date('2012-07-02')"
  end

  test "sysdate" do
    assert sysdate("dd-MM-yyyy", "UTC") == "sysdate('dd-MM-yyyy', 'UTC')"
    assert sysdate("dd-MM-yyyy") == "sysdate('dd-MM-yyyy')"
  end

  test "format" do
    expected = "format('%d - Mr. %s %s (%s)', id, name, surname, address)"
    actual = format("%d - Mr. %s %s (%s)", [:id, :name, :surname, :address])
    assert expected == actual
  end

  test "dijkstra" do
    assert dijkstra("$current", "#8:10", "weight", :out) == "dijkstra($current, #8:10, 'weight', 'OUT')"
    assert dijkstra("$current", "#8:10", "weight") == "dijkstra($current, #8:10, 'weight')"
  end

  test "shortestPath" do
    assert shortest_path("#8:32", "#8:10") == "shortestPath(#8:32, #8:10)"
    assert shortest_path("#8:32", "#8:10", :in) == "shortestPath(#8:32, #8:10, 'IN')"
    assert shortest_path("#8:32", "#8:10", :in, Friend) == "shortestPath(#8:32, #8:10, 'IN', 'Friend')"
    assert shortest_path("#8:32", "#8:10", nil, nil, %{"maxDepth" => 5}) == "shortestPath(#8:32, #8:10, null, null, {\"maxDepth\":5})"
  end

  test "distance" do
    assert distance(:x, :y, 52.20472, 0.14056) == "distance(x, y, 52.20472, 0.14056)"
  end

  test "distinct" do
    assert distinct(:name) == "distinct(name)"
    assert distinct("name") == "distinct(name)"
  end

  test "unionall" do
    assert unionall(:friends) == "unionall(friends)"
    assert unionall([:inEdges, :outEdges]) == "unionall(inEdges, outEdges)"
  end

  test "intersect" do
    assert intersect(:friends) == "intersect(friends)"
    assert intersect([:inEdges, :outEdges]) == "intersect(inEdges, outEdges)"
  end

  test "difference" do
    assert difference(:friends) == "difference(friends)"
    assert difference([:inEdges, :outEdges]) == "difference(inEdges, outEdges)"
  end

  test "symmetricDifference" do
    assert symmetric_difference(:friends) == "symmetricDifference(friends)"
    assert symmetric_difference([:inEdges, :outEdges]) == "symmetricDifference(inEdges, outEdges)"
  end

  test "set" do
    assert set("roles.name") == "set(roles.name)"
    assert set(:addresses) == "set(addresses)"
  end

  test "list" do
    assert list("roles.name") == "list(roles.name)"
    assert list(:addresses) == "list(addresses)"
  end

  test "map" do
    assert map("name", "roles.name") == "map(name, roles.name)"
    assert map(:name, :field) == "map(name, field)"
  end

  test "traversedElement" do
    assert traversed_element(-1) == "traversedElement(-1)"
    assert traversed_element(-1, 3) == "traversedElement(-1, 3)"
  end

  test "traversedEdge" do
    assert traversed_edge(-1) == "traversedEdge(-1)"
    assert traversed_edge(-1, 3) == "traversedEdge(-1, 3)"
  end

  test "traversedVertex" do
    assert traversed_vertex(-1) == "traversedVertex(-1)"
    assert traversed_vertex(-1, 3) == "traversedVertex(-1, 3)"
  end

  test "mode" do
    assert mode(:salary) == "mode(salary)"
    assert mode("salary") == "mode(salary)"
  end

  test "median" do
    assert median(:salary) == "median(salary)"
    assert median("salary") == "median(salary)"
  end

  test "percentile" do
    assert percentile(:salary, 95) == "percentile(salary, 95)"
    assert percentile(:salary, [25, 75]) == "percentile(salary, 25, 75)"
  end

  test "variance" do
    assert variance(:salary) == "variance(salary)"
    assert variance("salary") == "variance(salary)"
  end

  test "stddev" do
    assert stddev(:salary) == "stddev(salary)"
    assert stddev("salary") == "stddev(salary)"
  end

  test "uuid" do
    assert uuid() == "uuid()"
  end
end
