defmodule ExOrient.QueryBuilder do
  @moduledoc """
  Logic for building query strings to be used in DB commands. This is used in
  `ExOrient.DB` function calls.
  """

  alias MarcoPolo.RID

  @doc """
  Return a DB class name for a given module name or string.

      iex> ExOrient.QueryBuilder.class_name(Models.Person)
      "Person"

      iex> ExOrient.QueryBuilder.class_name("User")
      "User"

  """
  def class_name(%RID{cluster_id: c, position: p}), do: "##{c}:#{p}"
  def class_name(module) when is_binary(module), do: module
  def class_name(module) when is_atom(module) do
    module
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.fetch!(-1)
  end

  @doc """
  Wrap a given `str` in parentheses.

      iex> ExOrient.QueryBuilder.wrap_in_parens("hello")
      "(hello)"

  """
  def wrap_in_parens(str), do: "(#{str})"

  @doc """
  Wrap a given `str` in square brackets.

      iex> ExOrient.QueryBuilder.wrap_in_square_brackets("test")
      "[test]"

  """
  def wrap_in_square_brackets(str), do: "[#{str}]"

  @doc """
  Convert a single item to a list

      iex> ExOrient.QueryBuilder.to_list([:a, :b])
      [:a, :b]

      iex> ExOrient.QueryBuilder.to_list(:a)
      [:a]

  """
  def to_list(list) when is_list(list), do: list
  def to_list(single), do: [single]

  @doc """
  Put some parameters into a query string. We try not to use this if we don't
  have to.
  """
  def combine_params(query, params) do
    params
    |> Enum.to_list()
    |> Enum.reduce(query, fn({key, value}, acc) ->
      String.replace(acc, ":#{key}", value)
    end)
  end

  @doc """
  Add a let block to a query for a given `map`.

      iex> ExOrient.QueryBuilder.append_let(%{"$n" => :name}, "SELECT FROM Test", %{})
      {"SELECT FROM Test LET $n = name", %{}}

  """
  def append_let(nil, query, params), do: {query, params}

  def append_let(map, query, params) do
    block = map
    |> Map.to_list()
    |> Enum.map(fn
        ({var, {sub_query, sub_params}}) -> "#{var} = (#{combine_params(sub_query, sub_params)})"
        ({var, field}) -> "#{var} = #{field}"
      end)
    |> Enum.join(", ")

    {query <> " LET #{block}", params}
  end

  @doc """
  Append a where clause based on a map, keyword list, 3-elem tuple, or list of
  3-elem tuples. Maps, keyword lists, single tuples are all converted to lists
  of 3-elem tuples and passed down the line. You can also specify a logical
  operator, such as `:or`. `:and` is used by default if you have multiple fields
  in your where clause. If you're doing anything more complicated, you can also
  pass a string to use directly as the WHERE clause, although this is not
  preferred.
  """
  def append_where(clause_or_map, logical \\ :and, query, params)

  def append_where(nil, _logical, query, params) do
    {query, params}
  end

  def append_where(clause, _logical, query, params) when is_binary(clause) do
    {query <> " WHERE #{clause}", params}
  end

  def append_where(map, logical, query, params) when is_map(map) do
    map
    |> Map.to_list()
    |> Enum.map(fn({key, value}) -> {to_string(key), "=", value} end)
    |> append_where(logical, query, params)
  end

  def append_where(clause, logical, query, params) when is_tuple(clause) do
    append_where([clause], logical, query, params)
  end

  # For a keyword list: [name: "Paul", name: "Bob"]
  def append_where(clauses = [{_key, _val} | _rest], logical, query, params) do
    clauses
    |> Enum.map(fn({key, value}) -> {to_string(key), "=", value} end)
    |> append_where(logical, query, params)
  end

  # For the finally built list of clauses: [{"name", "=", "Paul"}, {"name", "=", "Bob"}]
  def append_where(clauses = [{_key, _op, _val} | _rest], logical, query, params) do
    # First, we build up a tuple like this:
    # {"name = :where_name_0", "where_name_0", "Paul"}
    clauses_keys_vals =
      clauses
      |> Enum.with_index(:rand.uniform * 1000 |> round())
      |> Enum.map(fn({{key, oper, value}, index}) ->
        case key do
          "@" <> rec_attr -> {"#{key} #{oper} :where_#{rec_attr}_#{index}", "where_#{rec_attr}_#{index}", value}
          "$" <> var -> {"#{key} #{oper} :where_#{var}_#{index}", "where_#{var}_#{index}", value}
          _ ->
            var = key |> to_string() |> String.split(".") |> Enum.at(0) # Support prop.toLowerCase()
            {"#{key} #{oper} :where_#{var}_#{index}", "where_#{var}_#{index}", value}
        end
      end)

    # Pull out the map of keys => values
    # %{"where_name_0" => "Paul"}
    map =
      clauses_keys_vals
      |> Enum.map(fn({_clause, key, val}) -> {key, val} end)
      |> Enum.into(%{})
      |> Map.merge(params)

    # Join all the clauses together
    # "name = :where_name_0 AND age = :where_age_1"
    clause =
      clauses_keys_vals
      |> Enum.map(fn({clause, _key, _val}) -> clause end)
      |> Enum.join(" #{logical |> to_string() |> String.upcase()} ")

    {query <> " WHERE #{clause}", map}
  end

  @doc """
  Add a group by clause to a given `query`. `field` can be a string or atom.

      iex> ExOrient.QueryBuilder.append_group_by(:name, "SELECT FROM Test", %{})
      {"SELECT FROM Test GROUP BY name", %{}}

  """
  def append_group_by(nil, query, params), do: {query, params}
  def append_group_by(field, query, params) do
    {query <> " GROUP BY #{field}", params}
  end

  @doc """
  Append an order by clause to a given `query`.

      iex> ExOrient.QueryBuilder.append_order_by(:name, "SELECT FROM Test", %{})
      {"SELECT FROM Test ORDER BY name ASC", %{}}

  """
  def append_order_by(fields, order \\ "ASC", query, params)
  def append_order_by(nil, _order, query, params), do: {query, params}
  def append_order_by(field, order, query, params) when is_atom(field), do: append_order_by([field], order, query, params)
  def append_order_by(field, order, query, params) when is_binary(field), do: append_order_by([field], order, query, params)
  def append_order_by(fields, order, query, params) do
    fields =
      fields
      |> Enum.map(&to_string/1)
      |> Enum.join(", ")

    order =
      order
      |> to_string()
      |> String.upcase()

    {query <> " ORDER BY #{fields} #{order}", params}
  end

  @doc """
  Append an unwind statement to a query

      iex> ExOrient.QueryBuilder.append_unwind(:friend, "SELECT FROM People", %{})
      {"SELECT FROM People UNWIND friend", %{}}

  """
  def append_unwind(nil, query, params), do: {query, params}
  def append_unwind(field, query, params) do
    {query <> " UNWIND #{field}", params}
  end

  @doc """
  Append a skip statement

      iex> ExOrient.QueryBuilder.append_skip(20, "SELECT FROM Test", %{})
      {"SELECT FROM Test SKIP 20", %{}}

  """
  def append_skip(nil, query, params), do: {query, params}
  def append_skip(number, query, params) do
    {query <> " SKIP #{number}", params}
  end

  @doc """
  Append a limit statement

      iex> ExOrient.QueryBuilder.append_limit(10, "SELECT FROM Test", %{})
      {"SELECT FROM Test LIMIT 10", %{}}

  """
  def append_limit(nil, query, params), do: {query, params}
  def append_limit(number, query, params) do
    {query <> " LIMIT #{number}", params}
  end

  @doc """
  Append fetch plan

      iex> ExOrient.QueryBuilder.append_fetchplan("*:-1", "SELECT FROM Test", %{})
      {"SELECT FROM Test FETCHPLAN *:-1", %{}}

  """
  def append_fetchplan(nil, query, params), do: {query, params}
  def append_fetchplan(plan, query, params) do
    {query <> " FETCHPLAN #{plan}", params}
  end

  @doc """
  Append timeout

      iex> ExOrient.QueryBuilder.append_timeout(5000, "SELECT FROM Test", %{})
      {"SELECT FROM Test TIMEOUT 5000", %{}}

      iex> ExOrient.QueryBuilder.append_timeout({5000, :return}, "SELECT FROM Test", %{})
      {"SELECT FROM Test TIMEOUT 5000 RETURN", %{}}

      iex> ExOrient.QueryBuilder.append_timeout({5000, :exception}, "SELECT FROM Test", %{})
      {"SELECT FROM Test TIMEOUT 5000 EXCEPTION", %{}}

  """
  def append_timeout(nil, query, params), do: {query, params}
  def append_timeout({millis, :return}, query, params), do: {query <> " TIMEOUT #{millis} RETURN", params}
  def append_timeout({millis, :exception}, query, params), do: {query <> " TIMEOUT #{millis} EXCEPTION", params}
  def append_timeout(millis, query, params), do: {query <> " TIMEOUT #{millis}", params}

  @doc """
  Append a lock statement

      iex> ExOrient.QueryBuilder.append_lock(:default, "SELECT FROM Test", %{})
      {"SELECT FROM Test LOCK DEFAULT", %{}}

      iex> ExOrient.QueryBuilder.append_lock(:record, "SELECT FROM Test", %{})
      {"SELECT FROM Test LOCK RECORD", %{}}

  """
  def append_lock(nil, query, params), do: {query, params}
  def append_lock(:default, query, params), do: {query <> " LOCK DEFAULT", params}
  def append_lock(:record, query, params), do: {query <> " LOCK RECORD", params}

  @doc """
  Append a parallel statement

      iex> ExOrient.QueryBuilder.append_parallel(true, "SELECT FROM Test", %{})
      {"SELECT FROM Test PARALLEL", %{}}

  """
  def append_parallel(nil, query, params), do: {query, params}
  def append_parallel(true, query, params), do: {query <> " PARALLEL", params}
  def append_parallel(false, query, params), do: {query, params}

  @doc """
  Append a nocache statement

      iex> ExOrient.QueryBuilder.append_nocache(true, "SELECT FROM Test", %{})
      {"SELECT FROM Test NOCACHE", %{}}

  """
  def append_nocache(nil, query, params), do: {query, params}
  def append_nocache(true, query, params), do: {query <> " NOCACHE", params}
  def append_nocache(false, query, params), do: {query, params}

  @doc """
  Append a values statement

      iex> ExOrient.QueryBuilder.append_values({[:name, :type], ["Elixir", "Awesome"]}, "INSERT INTO Test", %{})
      {"INSERT INTO Test (name, type) VALUES (:values_name, :values_type)", %{"values_name" => "Elixir", "values_type" => "Awesome"}}

  """
  def append_values(nil, query, params), do: {query, params}
  def append_values({fields, values}, query, params) do
    built_fields =
      fields
      |> Enum.map(&to_string/1)
      |> Enum.join(", ")
      |> wrap_in_parens()

    placeholders =
      fields
      |> Enum.map(&to_string/1)
      |> Enum.map(fn(field) -> ":values_#{field}" end)
      |> Enum.join(", ")
      |> wrap_in_parens()

    map =
    fields
    |> Enum.map(fn(field) -> "values_#{field}" end)
    |> Enum.zip(values)
    |> Enum.into(%{})
    |> Map.merge(params)

    {query <> " #{built_fields} VALUES #{placeholders}", map}
  end

  @type_tags [:binary, :long, :short, :int, :float, :double]

  @doc """
  Append a set statement

      iex> ExOrient.QueryBuilder.append_set([key: "val"], "INSERT INTO Test", %{})
      {"INSERT INTO Test SET key = :set_key", %{"set_key" => "val"}}

  """
  def append_set(nil, query, params), do: {query, params}
  def append_set(kv, query, params) do
    sets =
      kv
      |> Enum.map(fn
        ({key, {op, _}}) when op in @type_tags -> "#{key} = :set_#{key}"
        ({key, {q, p}}) -> "#{key} = (#{combine_params(q, p)})"
        ({key, _val}) -> "#{key} = :set_#{key}"
      end)
      |> Enum.join(", ")

    map =
      kv
      |> Enum.map(fn({key, val}) -> {"set_#{key}", val} end)
      |> Enum.into(params)

    {query <> " SET #{sets}", map}
  end

  @doc """
  Append a content statement

      iex> ExOrient.QueryBuilder.append_content(%{key: "val"}, "INSERT INTO Test", %{})
      {~s/INSERT INTO Test CONTENT {"key":"val"}/, %{}}

  """
  def append_content(nil, query, params), do: {query, params}
  def append_content(map, query, params) do
    json = Poison.encode!(map)
    {query <> " CONTENT #{json}", params}
  end

  @doc """
  Append a return statement

      iex> ExOrient.QueryBuilder.append_return("@rid", "INSERT INTO Test", %{})
      {"INSERT INTO Test RETURN @rid", %{}}

  """
  def append_return(nil, query, params), do: {query, params}
  def append_return(sql, query, params) do
    {query <> " RETURN #{sql}", params}
  end

  @doc """
  Append a from statement

      iex> ExOrient.QueryBuilder.append_from("#10:0", "CREATE EDGE Watched", %{})
      {"CREATE EDGE Watched FROM #10:0", %{}}

      iex> ExOrient.QueryBuilder.append_from("(SELECT FROM account)", "CREATE EDGE Watched", %{})
      {"CREATE EDGE Watched FROM (SELECT FROM account)", %{}}

  """
  def append_from(nil, query, params), do: {query, params}

  def append_from({sub_query, sub_params}, query, params) do
    {query <> " FROM (#{sub_query})", Map.merge(sub_params, params)}
  end

  def append_from(rid = %RID{}, query, params) do
    append_from(class_name(rid), query, params)
  end

  def append_from(rid = "#" <> _, query, params) do
    {query <> " FROM #{rid}", params}
  end

  def append_from(class, query, params) do
    {query <> " FROM #{class_name(class)}", params}
  end

  @doc """
  Append an increment statement

      iex> ExOrient.QueryBuilder.append_increment([number: 5], "UPDATE Counter", %{})
      {"UPDATE Counter INCREMENT number = :increment_number", %{"increment_number" => 5}}

  """
  def append_increment(nil, query, params), do: {query, params}
  def append_increment(kv, query, params) do
    fields =
      kv
      |> Enum.map(fn({field, _amt}) -> "#{field} = :increment_#{field}" end)
      |> Enum.join(", ")

    params =
      kv
      |> Enum.map(fn({key, val}) -> {"increment_#{key}", val} end)
      |> Enum.into(params)

    {query <> " INCREMENT #{fields}", params}
  end

  @doc """
  Append an add statement

      iex> ExOrient.QueryBuilder.append_add([something: "#9:0"], "UPDATE Person", %{})
      {"UPDATE Person ADD something = :add_something", %{"add_something" => "#9:0"}}

  """
  def append_add(nil, query, params), do: {query, params}
  def append_add(kv, query, params) do
    fields =
      kv
      |> Enum.map(fn({field, _val}) -> "#{field} = :add_#{field}" end)
      |> Enum.join(", ")

    params =
      kv
      |> Enum.map(fn({key, val}) -> {"add_#{key}", val} end)
      |> Enum.into(params)

    {query <> " ADD #{fields}", params}
  end

  @doc """
  Append a remove statement

      iex> ExOrient.QueryBuilder.append_remove(:name, "UPDATE ProgrammingLanguage", %{})
      {"UPDATE ProgrammingLanguage REMOVE name", %{}}

      iex> ExOrient.QueryBuilder.append_remove([meta: "type"], "UPDATE ProgrammingLanguage", %{})
      {"UPDATE ProgrammingLanguage REMOVE meta = :remove_meta", %{"remove_meta" => "type"}}

  """
  def append_remove(nil, query, params), do: {query, params}
  def append_remove(field, query, params) when is_atom(field), do: append_remove([field], query, params)
  def append_remove(field, query, params) when is_binary(field), do: append_remove([field], query, params)
  def append_remove(list, query, params) when is_list(list) do
    fields =
      list
      |> Enum.map(fn
           {field, _val} -> "#{field} = :remove_#{field}"
           field -> to_string(field)
         end)
      |> Enum.join(", ")

    case hd(list) do
      {_, _} ->
        params =
          list
          |> Enum.map(fn({key, val}) -> {"remove_#{key}", val} end)
          |> Enum.into(params)
        {query <> " REMOVE #{fields}", params}
      _ ->
        {query <> " REMOVE #{fields}", params}
    end
  end

  @doc """
  Append a put statement

      iex> ExOrient.QueryBuilder.append_put([addresses: {"CLE", "#12:0"}], "UPDATE Person", %{})
      {"UPDATE Person PUT addresses = :put_addresses_key, :put_addresses_val", %{"put_addresses_key" => "CLE", "put_addresses_val" => "#12:0"}}

  """
  def append_put(nil, query, params), do: {query, params}
  def append_put(list, query, params) do
    fields =
      list
      |> Enum.map(fn({field, _}) -> "#{field} = :put_#{field}_key, :put_#{field}_val" end)
      |> Enum.join(", ")

    params =
      list
      |> Enum.flat_map(fn({field, {key, val}}) -> [{"put_#{field}_key", key}, {"put_#{field}_val", val}] end)
      |> Enum.into(params)

    {query <> " PUT #{fields}", params}
  end

  @doc """
  Append a merge statement

      iex> ExOrient.QueryBuilder.append_merge(%{key: "val"}, "UPDATE Person", %{})
      {~s/UPDATE Person MERGE {"key":"val"}/, %{}}

  """
  def append_merge(nil, query, params), do: {query, params}
  def append_merge(map, query, params) do
    json = Poison.encode!(map)
    {query <> " MERGE #{json}", params}
  end

  @doc """
  Append an upsert statement

      iex> ExOrient.QueryBuilder.append_upsert(true, "UPDATE Person", %{})
      {"UPDATE Person UPSERT", %{}}

  """
  def append_upsert(nil, query, params), do: {query, params}
  def append_upsert(true, query, params), do: {query <> " UPSERT", params}
  def append_upsert(false, query, params), do: {query, params}

  @doc """
  Append a cluster statement

      iex> ExOrient.QueryBuilder.append_cluster("Name", "CREATE VERTEX V1", %{})
      {"CREATE VERTEX V1 CLUSTER Name", %{}}

  """
  def append_cluster(nil, query, params), do: {query, params}
  def append_cluster(cluster, query, params), do: {query <> " CLUSTER #{cluster}", params}

  @doc """
  Append a from statement

      iex> ExOrient.QueryBuilder.append_to("#10:0", "CREATE EDGE Watched", %{})
      {"CREATE EDGE Watched TO #10:0", %{}}

      iex> ExOrient.QueryBuilder.append_to("SELECT FROM account", "CREATE EDGE Watched", %{})
      {"CREATE EDGE Watched TO (SELECT FROM account)", %{}}

  """
  def append_to(nil, query, params), do: {query, params}

  def append_to({sub_query, sub_params}, query, params) do
    {query <> " TO (#{sub_query})", Map.merge(sub_params, params)}
  end

  def append_to(rid = %RID{}, query, params) do
    append_to(class_name(rid), query, params)
  end

  def append_to(rid = "#" <> _, query, params) do
    {query <> " TO #{rid}", params}
  end

  def append_to(subquery, query, params) do
    {query <> " TO (#{subquery})", params}
  end

  @doc """
  Append retry statement

      iex> ExOrient.QueryBuilder.append_retry(10, "CREATE EDGE Test", %{})
      {"CREATE EDGE Test RETRY 10", %{}}

  """
  def append_retry(nil, query, params), do: {query, params}
  def append_retry(num, query, params), do: {query <> " RETRY #{num}", params}

  @doc """
  Append wait statement

      iex> ExOrient.QueryBuilder.append_wait(100, "CREATE EDGE Test", %{})
      {"CREATE EDGE Test WAIT 100", %{}}

  """
  def append_wait(nil, query, params), do: {query, params}
  def append_wait(millis, query, params), do: {query <> " WAIT #{millis}", params}

  @doc """
  Append batch statement

      iex> ExOrient.QueryBuilder.append_batch(200, "CREATE EDGE Test", %{})
      {"CREATE EDGE Test BATCH 200", %{}}

  """
  def append_batch(nil, query, params), do: {query, params}
  def append_batch(num, query, params), do: {query <> " BATCH #{num}", params}

  @doc """
  Append vertex statement

      iex> ExOrient.QueryBuilder.append_vertex("#10:0", "DELETE", %{})
      {"DELETE VERTEX #10:0", %{}}

  """
  def append_vertex(nil, query, params), do: {query, params}
  def append_vertex(class, query, params), do: {query <> " VERTEX #{class_name(class)}", params}

  @doc """
  Append edge statement

      iex> ExOrient.QueryBuilder.append_edge("#10:0", "DELETE", %{})
      {"DELETE EDGE #10:0", %{}}

  """
  def append_edge(nil, query, params), do: {query, params}
  def append_edge(class, query, params), do: {query <> " EDGE #{class_name(class)}", params}

  @doc """
  Append extends statement

      iex> ExOrient.QueryBuilder.append_extends("E", "CREATE CLASS Person", %{})
      {"CREATE CLASS Person EXTENDS E", %{}}

  """
  def append_extends(nil, query, params), do: {query, params}
  def append_extends(class, query, params), do: {query <> " EXTENDS #{class_name(class)}", params}

  @doc """
  Append abstract statement

      iex> ExOrient.QueryBuilder.append_abstract(true, "CREATE CLASS Person", %{})
      {"CREATE CLASS Person ABSTRACT", %{}}

  """
  def append_abstract(nil, query, params), do: {query, params}
  def append_abstract(true, query, params), do: {query <> " ABSTRACT", params}
  def append_abstract(false, query, params), do: {query, params}

  @doc """
  Append an on statement

      iex> ExOrient.QueryBuilder.append_on("Movie (thumbs)", "CREATE INDEX thumbsAuthor", %{})
      {"CREATE INDEX thumbsAuthor ON Movie (thumbs)", %{}}

  """
  def append_on(nil, query, params), do: {query, params}
  def append_on(on, query, params), do: {query <> " ON #{on}", params}

  @doc """
  Append a type

      iex> ExOrient.QueryBuilder.append_type(:string, "CREATE INDEX Test", %{})
      {"CREATE INDEX Test STRING", %{}}

  """
  def append_type(nil, query, params), do: {query, params}
  def append_type(type, query, params) do
    type = type |> to_string() |> String.upcase()
    {query <> " #{type}", params}
  end

  @doc """
  Append metadata

      iex> ExOrient.QueryBuilder.append_metadata(%{ignoreNullValues: false}, "CREATE INDEX Test", %{})
      {~S/CREATE INDEX Test METADATA {"ignoreNullValues":false}/, %{}}

  """
  def append_metadata(nil, query, params), do: {query, params}
  def append_metadata(map, query, params) do
    json = Poison.encode!(map)
    {query <> " METADATA #{json}", params}
  end

  @doc """
  Append unsafe

      iex> ExOrient.QueryBuilder.append_unsafe(true, "TRUNCATE CLASS Person", %{})
      {"TRUNCATE CLASS Person UNSAFE", %{}}

  """
  def append_unsafe(nil, query, params), do: {query, params}
  def append_unsafe(true, query, params), do: {query <> " UNSAFE", params}
  def append_unsafe(false, query, params), do: {query, params}

  @doc """
  Append polymorphic

      iex> ExOrient.QueryBuilder.append_polymorphic(true, "TRUNCATE CLASS Person", %{})
      {"TRUNCATE CLASS Person POLYMORPHIC", %{}}

  """
  def append_polymorphic(nil, query, params), do: {query, params}
  def append_polymorphic(true, query, params), do: {query <> " POLYMORPHIC", params}
  def append_polymorphic(false, query, params), do: {query, params}

  @doc """
  Append force

      iex> ExOrient.QueryBuilder.append_force(true, "DROP PROPERTY Person.name", %{})
      {"DROP PROPERTY Person.name FORCE", %{}}

  """
  def append_force(nil, query, params), do: {query, params}
  def append_force(true, query, params), do: {query <> " FORCE", params}
  def append_force(false, query, params), do: {query, params}
end
