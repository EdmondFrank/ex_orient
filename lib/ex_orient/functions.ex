defmodule ExOrient.Functions do
  @moduledoc """
  DSL for http://orientdb.com/docs/last/SQL-Functions.html

  An attempt to move as much of the query language out of strings as possible.

  Usage examples:

        > import ExOrient.DB
        > import ExOrient.Functions
        > select(out("works_for") |> expand(), from: Person) |> exec()
        > select(out("owns") |> expand(), from: Person) |> exec()
        > select(count("*"), from: Person) |> exec()

  > Important note:
  > Some function names collide with Elixir syntax. These functions have `o_`
  > prepended onto their names. For example, `o_in` instead of `in`.

  """

  import ExOrient.QueryBuilder, only: [class_name: 1]

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#out

      > DB.select(out(Following), from: Person)

  """
  def out, do: out([])
  def out(str) when not is_list(str), do: out([str])
  def out(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("out")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#in

      > DB.select(o_in(Following), from: Person)

  """
  def o_in, do: o_in([])
  def o_in(str) when not is_list(str), do: o_in([str])
  def o_in(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("in")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#both

      > DB.select(both(Following), from: Person)

  """
  def both, do: both([])
  def both(str) when not is_list(str), do: both([str])
  def both(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("both")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#oute

      > DB.select(out_e(), from: Person)

  """
  def out_e, do: out_e([])
  def out_e(str) when not is_list(str), do: out_e([str])
  def out_e(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("outE")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#ine

      > DB.select(in_e(), from: Person)

  """
  def in_e, do: in_e([])
  def in_e(str) when not is_list(str), do: in_e([str])
  def in_e(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("inE")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#bothe

      > DB.select(both_e(), from: Person)

  """
  def both_e, do: both_e([])
  def both_e(str) when not is_list(str), do: both_e([str])
  def both_e(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("bothE")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#outv

      > DB.select(out_v(), from: Person)

  """
  def out_v do
    "outV()"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#inv

      > DB.select(in_v(), from: Person)

  """
  def in_v do
    "inV()"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#eval

      > DB.select(eval("1 + 2"), from: Person)

  """
  def eval(expr) do
    [expr]
    |> quotes()
    |> commas()
    |> wrap_in_func("eval")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#coalesce

      > DB.select(coalesce(:amount), from: Person)

  """
  def coalesce(field) when not is_list(field), do: coalesce([field])
  def coalesce(list) do
    list
    |> commas()
    |> wrap_in_func("coalesce")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#if

      > DB.select(o_if("true", "Do if true", "Do if false"), from: Person)

  """
  def o_if(expr, if_true, if_false) do
    "if('#{expr}', '#{if_true}', '#{if_false}')"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#expand

      > DB.select(expand(out(Following)), from: Person)

  """
  def expand(str) do
    wrap_in_func(str, "expand")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#first

      > DB.select(first(:addresses), from: Person)

  """
  def first(field) do
    wrap_in_func(field, "first")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#last

      > DB.select(last(:addresses), from: Person)

  """
  def last(field) do
    wrap_in_func(field, "last")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#count

      > DB.select(count("*"), from: Person)

  """
  def count(field) do
    wrap_in_func(field, "COUNT")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#min

      > DB.select(o_min(:salary), from: Person)

  """
  def o_min(field) when not is_list(field), do: o_min([field])
  def o_min(fields) do
    fields
    |> commas()
    |> wrap_in_func("min")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#max

      > DB.select(o_max(:salary), from: Person)

  """
  def o_max(field) when not is_list(field), do: o_max([field])
  def o_max(fields) do
    fields
    |> commas()
    |> wrap_in_func("max")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#abs

      > DB.select(o_abs(:net_worth), from: Person)

  """
  def o_abs(field) do
    wrap_in_func(field, "abs")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#avg

      > DB.select(avg(:salary), from: Person)

  """
  def avg(field) do
    wrap_in_func(field, "avg")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#sum

      > DB.select(sum(:salary), from: Person)

  """
  def sum(field) do
    wrap_in_func(field, "sum")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#date

      > DB.select(date("03-08-2016", "MM-dd-yyyy", "UTC"), from: Person)

  """
  def date(d, f, t), do: date([d, f, t])
  def date(d, f), do: date([d, f])
  def date(d) when not is_list(d), do: date([d])
  def date(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("date")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#sysdate

      > DB.select(sysdate("MM-dd-yyyy", "UTC"), from: Person)

  """
  def sysdate(f, t), do: sysdate([f, t])
  def sysdate(f) when not is_list(f), do: sysdate([f])
  def sysdate(list) do
    list
    |> quotes()
    |> commas()
    |> wrap_in_func("sysdate")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#format

      > DB.select(format("Mr. %s", [:surname]), from: Person)

  """
  def format(str, fields) do
    str = "'#{str}'"
    [str | fields]
    |> commas()
    |> wrap_in_func("format")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#dijkstra

      > DB.select(dijkstra("#11:0", "#11:27"), from: Person)

  """
  def dijkstra(source, dest, field) do
    "dijkstra(#{source}, #{dest}, '#{field}')"
  end

  def dijkstra(source, dest, field, dir) do
    "dijkstra(#{source}, #{dest}, '#{field}', '#{dir |> Atom.to_string() |> String.upcase()}')"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#shortestpath

      > DB.select(shortest_path("#11:0", "#11:27"), from: Person)

  """
  def shortest_path(source, dest) do
    "shortestPath(#{source}, #{dest})"
  end

  def shortest_path(source, dest, dir) do
    "shortestPath(#{source}, #{dest}, '#{dir |> Atom.to_string() |> String.upcase()}')"
  end

  def shortest_path(source, dest, nil, class) do
    "shortestPath(#{source}, #{dest}, null, '#{class_name(class)}')"
  end

  def shortest_path(source, dest, dir, class) do
    "shortestPath(#{source}, #{dest}, '#{dir |> Atom.to_string() |> String.upcase()}', '#{class_name(class)}')"
  end

  def shortest_path(source, dest, nil, nil, opts) do
    "shortestPath(#{source}, #{dest}, null, null, #{Poison.encode!(opts)})"
  end

  def shortest_path(source, dest, dir, class, opts) do
    "shortestPath(#{source}, #{dest}, '#{dir |> Atom.to_string() |> String.upcase()}', '#{class_name(class)}', #{Poison.encode!(opts)})"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#distance

      > DB.select(distance(:x, :y, 52.02342, 13.32142), from: Person)

  """
  def distance(x_field, y_field, x, y) do
    "distance(#{x_field}, #{y_field}, #{x}, #{y})"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#distinct

      > DB.select(distinct(:surname), from: Person)

  """
  def distinct(field) do
    wrap_in_func(field, "distinct")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#unionall

      > DB.select(unionall(:friends), from: Person)

  """
  def unionall(field) when not is_list(field), do: unionall([field])
  def unionall(fields) do
    fields
    |> commas()
    |> wrap_in_func("unionall")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#intersect

      > DB.select(intersect(:friends), from: Person)

  """
  def intersect(field) when not is_list(field), do: intersect([field])
  def intersect(fields) do
    fields
    |> commas()
    |> wrap_in_func("intersect")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#difference

      > DB.select(difference(:friends), from: Person)

  """
  def difference(field) when not is_list(field), do: difference([field])
  def difference(fields) do
    fields
    |> commas()
    |> wrap_in_func("difference")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#symmetricdifference

      > DB.select(symmetric_difference(:friends), from: Person)

  """
  def symmetric_difference(field) when not is_list(field), do: symmetric_difference([field])
  def symmetric_difference(fields) do
    fields
    |> commas()
    |> wrap_in_func("symmetricDifference")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#set

      > DB.select(set("roles.name"), from: Person)

  """
  def set(field) do
    wrap_in_func(field, "set")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#list

      > DB.select(list("roles.name"), from: Person)

  """
  def list(field) do
    wrap_in_func(field, "list")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#map

      > DB.select(map("name", "roles.name"), from: Person)

  """
  def map(key, value) do
    "map(#{key}, #{value})"
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#traversedelement

      > DB.select(traversed_element(-1), from: "TRAVERSE out() FROM #12:12")

  """
  def traversed_element(index, items), do: traversed_element([index, items])
  def traversed_element(index) when not is_list(index), do: traversed_element([index])
  def traversed_element(list) do
    list
    |> commas()
    |> wrap_in_func("traversedElement")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#traversededge

      > DB.select(traversed_edge(-1), from: "TRAVERSE out() FROM #12:12")

  """
  def traversed_edge(index, items), do: traversed_edge([index, items])
  def traversed_edge(index) when not is_list(index), do: traversed_edge([index])
  def traversed_edge(list) do
    list
    |> commas()
    |> wrap_in_func("traversedEdge")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#traversedvertex

      > DB.select(traversed_vertex(-1), from: "TRAVERSE out() FROM #12:12")

  """
  def traversed_vertex(index, items), do: traversed_vertex([index, items])
  def traversed_vertex(index) when not is_list(index), do: traversed_vertex([index])
  def traversed_vertex(list) do
    list
    |> commas()
    |> wrap_in_func("traversedVertex")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#mode

      > DB.select(mode(:salary), from: Person)

  """
  def mode(field) do
    wrap_in_func(field, "mode")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#median

      > DB.select(mode(:median), from: Person)

  """
  def median(field) do
    wrap_in_func(field, "median")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#percentile

      > DB.select(percentile(:salary, 95), from: Person)

  """
  def percentile(field, p) when not is_list(p), do: percentile(field, [p])
  def percentile(field, ps) do
    [field | ps]
    |> commas()
    |> wrap_in_func("percentile")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#variance

      > DB.select(variance(:salary), from: Person)

  """
  def variance(field) do
    wrap_in_func(field, "variance")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#stddev

      > DB.select(stddev(:salary), from: Person)

  """
  def stddev(field) do
    wrap_in_func(field, "stddev")
  end

  @doc """
  http://orientdb.com/docs/last/SQL-Functions.html#uuid

      > DB.select(uuid(), from: Person)

  """
  def uuid do
    "uuid()"
  end

  # ex: wrap_in_func("salary", "sum") => "sum(salary)"
  defp wrap_in_func(params, func) do
    "#{func}(#{params})"
  end

  # ex: quotes(["a", "b"]) => "'a', 'b'"
  defp quotes(list) do
    Enum.map(list, fn(str) -> "'#{class_name(str)}'" end)
  end

  # ex: commas(["a", "b"]) => "a, b"
  defp commas(list) do
    Enum.join(list, ", ")
  end
end
