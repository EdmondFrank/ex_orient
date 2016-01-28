# ExOrient

An OrientDB query builder providing a nicer syntax to Orient SQL and uses
[MarcoPolo](https://github.com/MyMedsAndMe/marco_polo) to execute commands.

## Installation

  1. Add ex_orient to your list of dependencies in `mix.exs`:
    ```elixir
    def deps do
      [{:ex_orient, "~> 0.1.0"}]
    end
    ```

  2. Ensure ex_orient is started before your application:
    ```elixir
    def application do
      [applications: [:ex_orient]]
    end
    ```


## Configuration

In your config.exs file, add the following:

```elixir
config :ex_orient,
  pool_size: 5,
  pool_max_overflow: 10,
  user: "admin",
  password: "admin",
  connection: {:db, "GratefulDeadConcerts", :document}
```

Adjust the values to fit your needs.

## Usage

The naming is as similar as possibly to the SQL commands, and every command
takes a keyword list of commands. The functions return a 2-tuple of a query
string and a map of params (the map is passed off to MarcoPolo, which does
the job of interpolating them into the string). To execute a command, simply
pipe it to `DB.exec/1` or `DB.command/1`. This library was written this way
to accomodate subqueries.

Here's a simple example:

```elixir
command = ExOrient.DB.insert(into: ProgrammingLanguage, set: [name: "Elixir"])
# {"INSERT INTO ProgrammingLanguage SET name = :set_name", %{"set_name" => "Elixir"}}

DB.exec(command)
```

And an example of building up a larger query using subqueries:

```elixir
alias ExOrient.DB

DB.create(
  edge: "works_for",
  from: DB.select(from: Employee, where: %{name: "Paul"}),
  to: DB.select(from: Company, where: %{name: "Remesh"})
) |> DB.exec()
```

A relatively comprehensive example performing lots of operations:

```elixir
iex(1)> alias ExOrient.DB
iex(2)> alias MarcoPolo.Document

iex(3)> DB.create(class: Employee, extends: "V") |> DB.exec()
{:ok, 26}

iex(4)> DB.create(class: Company, extends: "V") |> DB.exec()
{:ok, 27}

iex(5)> DB.create(class: "works_for", extends: "E") |> DB.exec()
{:ok, 28}

iex(6)> DB.create(class: "owns", extends: "E") |> DB.exec()
{:ok, 29}

iex(7)> DB.insert(into: Employee, set: [name: "Elon"]) |> DB.exec()
{:ok,
 %MarcoPolo.Document{class: "Employee", fields: %{"name" => "Elon"},
  rid: #MarcoPolo.RID<#22:0>, version: 1}}

iex(8)> DB.insert(into: Employee, content: %{name: "John Doe"}) |> DB.exec()
{:ok,
 %MarcoPolo.Document{class: "Employee", fields: %{"name" => "John Doe"},
  rid: #MarcoPolo.RID<#22:1>, version: 1}}

iex(9)> DB.insert(into: Employee, content: %{name: "Jane Doe"}) |> DB.exec()
{:ok,
 %MarcoPolo.Document{class: "Employee", fields: %{"name" => "Jane Doe"},
  rid: #MarcoPolo.RID<#22:2>, version: 1}}

iex(10)> DB.insert(into: Company, set: [name: "Tesla"]) |> DB.exec()
{:ok,
 %MarcoPolo.Document{class: "Company", fields: %{"name" => "Tesla"},
  rid: #MarcoPolo.RID<#23:0>, version: 1}}

iex(11)> DB.insert(into: Company, set: [name: "SpaceX"]) |> DB.exec()
{:ok,
 %MarcoPolo.Document{class: "Company", fields: %{"name" => "SpaceX"},
  rid: #MarcoPolo.RID<#23:1>, version: 1}}

iex(12)> employees = DB.select(from: Employee, where: [name: "John Doe", name: "Jane Doe", name: "Elon"], logical: :or)
{"SELECT FROM Employee WHERE name = :where_name_444 OR name = :where_name_445 OR name = :where_name_446",
 %{"where_name_444" => "John Doe", "where_name_445" => "Jane Doe",
   "where_name_446" => "Elon"}}

iex(13)> elon = "#22:0"
"#22:0"

iex(14)> companies = DB.select(from: Company, where: [name: "Tesla", name: "SpaceX"], logical: :or)
{"SELECT FROM Company WHERE name = :where_name_723 OR name = :where_name_724",
 %{"where_name_723" => "Tesla", "where_name_724" => "SpaceX"}}

iex(16)> DB.create(edge: "owns", from: elon, to: companies) |> DB.exec()
{:ok,
 [%MarcoPolo.Document{class: "owns",
   fields: %{"in" => #MarcoPolo.RID<#23:0>, "out" => #MarcoPolo.RID<#22:0>},
   rid: #MarcoPolo.RID<#26:0>, version: 1},
  %MarcoPolo.Document{class: "owns",
   fields: %{"in" => #MarcoPolo.RID<#23:1>, "out" => #MarcoPolo.RID<#22:0>},
   rid: #MarcoPolo.RID<#26:1>, version: 2}]}

iex(18)> DB.create(edge: "works_for", from: employees, to: "#23:1") |> DB.exec()
{:ok,
 [%MarcoPolo.Document{class: "works_for",
   fields: %{"in" => #MarcoPolo.RID<#23:1>, "out" => #MarcoPolo.RID<#22:2>},
   rid: #MarcoPolo.RID<#24:5>, version: 1},
  %MarcoPolo.Document{class: "works_for",
   fields: %{"in" => #MarcoPolo.RID<#23:1>, "out" => #MarcoPolo.RID<#22:0>},
   rid: #MarcoPolo.RID<#24:6>, version: 2},
  %MarcoPolo.Document{class: "works_for",
   fields: %{"in" => #MarcoPolo.RID<#23:1>, "out" => #MarcoPolo.RID<#22:1>},
   rid: #MarcoPolo.RID<#24:7>, version: 2}]}

iex(21)> DB.select(["expand(in('works_for'))"], from: Company, where: %{"name.toLowerCase()": "spacex"}) |> DB.exec()
{:ok,
 [%MarcoPolo.Document{class: "Employee",
   fields: %{"name" => "Jane Doe",
     "out_works_for" => {:link_bag, [#MarcoPolo.RID<#24:5>]}},
   rid: #MarcoPolo.RID<#22:2>, version: 2},
  %MarcoPolo.Document{class: "Employee",
   fields: %{"name" => "Elon",
     "out_owns" => {:link_bag, [#MarcoPolo.RID<#26:0>, #MarcoPolo.RID<#26:1>]},
     "out_works_for" => {:link_bag, [#MarcoPolo.RID<#24:6>]}},
   rid: #MarcoPolo.RID<#22:0>, version: 3},
  %MarcoPolo.Document{class: "Employee",
   fields: %{"name" => "John Doe",
     "out_works_for" => {:link_bag, [#MarcoPolo.RID<#24:7>]}},
   rid: #MarcoPolo.RID<#22:1>, version: 2}]}
```

## Contributing

Run tests (this requires a connection to a local database, check the config file):
```
mix test
```

Run tests excluding the ones that require a database connection:
```
mix test --exclude db
```

Make a Pull Request.
