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

Some examples:

```elixir
iex> alias ExOrient.DB
iex> alias MarcoPolo.Document

iex> DB.create(class: Person)
17

iex> %Document{rid: paul_rid} = DB.insert(into: Person, set: [name: "Paul", age: 21])
%MarcoPolo.Document{class: "Person", fields: %{"age" => 21, "name" => "Paul"},
  rid: #MarcoPolo.RID<#11:8>, version: 1}

iex> %Document{rid: john_rid} = DB.insert(into: Person, content: %{name: "John", age: 32})
MarcoPolo.Document{class: "Person", fields: %{"age" => 32, "name" => "John"},
  rid: #MarcoPolo.RID<#11:9>, version: 1}

iex> DB.select(from: Person)
[%MarcoPolo.Document{class: "Person", fields: %{"age" => 21, "name" => "Paul"},
  rid: #MarcoPolo.RID<#11:8>, version: 1},
%MarcoPolo.Document{class: "Person", fields: %{"age" => 32, "name" => "John"},
  rid: #MarcoPolo.RID<#11:9>, version: 1}]

iex> DB.select(from: Person, where: %{name: "Paul"})
[%MarcoPolo.Document{class: "Person", fields: %{"age" => 21, "name" => "Paul"},
  rid: #MarcoPolo.RID<#11:8>, version: 1}]

iex> DB.select(from: Person, where: %{"name.toLowerCase()": "john"})
[%MarcoPolo.Document{class: "Person", fields: %{"age" => 32, "name" => "John"},
  rid: #MarcoPolo.RID<#11:9>, version: 1}]

iex> DB.select(from: Person, where: {:age, "<", 25})
[%MarcoPolo.Document{class: "Person", fields: %{"age" => 21, "name" => "Paul"},
  rid: #MarcoPolo.RID<#11:8>, version: 1}]

iex> DB.delete(from: paul_rid)
1

iex> DB.drop(class: Person)
true
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
