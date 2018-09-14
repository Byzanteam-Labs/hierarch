# Hierarch

[![CircleCI](https://circleci.com/gh/GreenNerd-Labs/hierarch/tree/develop.svg?style=svg)](https://circleci.com/gh/GreenNerd-Labs/hierarch/tree/develop)
[![Hex.pm](https://img.shields.io/hexpm/v/hierarch.svg)](https://hex.pm/packages/hierarch)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/hierarch/Hierarch.html)

Hierarch helps you to build tree structure(hierarchy) for ecto models with ltree(Postgres).

## Installation

Add `hierarch` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hierarch, "~> 0.1.2"}
  ]
end
```

Enable ltree extension:
```elixir
execute "CREATE EXTENSION IF NOT EXISTS ltree"
```
Add GIST index:
```elixir
create index(:catelogs, [:path], using: "GIST")
```

## Example

### Set `types` at config/config.exs or your environment config file
```elixir
config :my_app, MyApp.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Hierarch.Postgrex.Types
```

### Write a migration for this functionality
```elixir
defmodule MyApp.Repo.Migrations.CreateCatelogs do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS ltree" # Enables Ltree action

    create table(:catelogs, primary_key: false) do
      add :id, :uuid, primary_key: true # the primary key is UUID
      add :name, :string
      add :path, :ltree

      timestamps()
    end

    create index(:catelogs, [:path], using: "GIST") # Add GIST index to query
  end
end
```

### Use Hierarch in your schema
Options:
- path_column (default: `:path`): the name of the database column which stores hierarchy data;

```elixir
defmodule MyApp.Catelog do
  use Ecto.Schema
  use Hierarch

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "catelogs" do
    field :name, :string
    field :path, Hierarch.Ecto.UUIDLTree # Set to `UUIDLTree` if the path is ltree type

    timestamps()
  end
end
```

### 🔢Use Hierarch with `bigint` or `integer` primary key, and custom path_column
```elixir
defmodule MyApp.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS ltree" # Enables Ltree action

    create table(:organizations) do
      add :name, :string
      add :ancestry, :ltree, null: false, default: ""
    end

    create index(:organizations, [:ancestry], using: "GIST")
  end
end
```

```elixir
defmodule MyApp.Organization do
  @moduledoc false
  use Ecto.Schema
  use Hierarch, path_column: :ancestry # set path_column

  schema "organizations" do
    field :name, :string
    field :ancestry, Hierarch.Ecto.LTree # Use LTree for bigint or integer primary key
  end
end
```

## Usage
### `build_child_of/2`
Take the parent struct and attributes struct, return a child struct.
```elixir
parent = %Catelog{
  id: "570526aa-e2f3-49a7-870a-c150d3bf6ac9",
  name: "Top",
  path: ""
}
catelog = Catelog.build_child_of(parent, %{name: "Top.Science"})
#  %Catelog{
#    id: nil,
#    name: "Top.Science",
#    path: "570526aa-e2f3-49a7-870a-c150d3bf6ac9"
#  }
```

### `is_root?/1`
Detect a struct whether a root.
```elixir
catelog = %Catelog{
  id: "570526aa-e2f3-49a7-870a-c150d3bf6ac9",
  name: "Top",
  path: ""
}
Catelog.is_root?(catelog) # true
```

### `parent/1`
Return the parent query expression of the given struct, return `nil` if it is the root.
```elixir
catelog = %Catelog{
  id: "570526aa-e2f3-49a7-870a-c150d3bf6ac9",
  name: "Top",
  path: ""
}
Catelog.parent(catelog) |> Repo.one # nil
```

### `root/1`
Return the root query expression of the given struct, return itself if it is the root.
```elixir
catelog = %Catelog{
  id: "570526aa-e2f3-49a7-870a-c150d3bf6ac9",
  name: "Top",
  path: ""
}
Catelog.root(catelog) |> Repo.one # return itself `catelog`
```

### `ancestors/2`
Return the ancestors query expression of the given struct.
Options:
- `:with_self` - when true to include itself. Defaults to false
```elixir
catelog = %Catelog{
  id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
  name: "Top.Hobbies",
  path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
}
Catelog.ancestors(catelog) |> Repo.all
#  [%Catelog{
#    id: "a9ae8f40-b016-4bf9-8224-e2755466e699",
#    name: "Top",
#    path: ""
#  }]

Catelog.ancestors(catelog, with_self: true) |> Repo.all
#  [
#    %Catelog{
#      id: "a9ae8f40-b016-4bf9-8224-e2755466e699",
#      name: "Top",
#      path: ""
#    },
#    %Catelog{
#      id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
#      name: "Top.Hobbies",
#      path: "a9ae8f40-b016-4bf9-8224-e2755466e699"
#    }
#  ]

```

### `descendants/2`
Return the descendants query expression of the given struct.
Options:
- `:with_self` - when true to include itself. Defaults to false
```elixir
catelog = %Catelog{
  id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
  name: "Top.Hobbies",
  path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
}
Catelog.descendants(catelog) |> Repo.all
#  [
#    %Catelog{
#      id: "6ff8db2e-5c01-4e82-a25b-4c1568df1efb",
#      name: "Top.Hobbies.Amateurs_Astronomy",
#      path: "a9ae8f40-b016-4bf9-8224-e2755466e699.06a84054-8827-42c2-9b75-25ed75e6d5f8"
#    }
#  ]
```

### `siblings/2`
Return the siblings query expression of the given struct.
Options:
- `:with_self` - when true to include itself. Defaults to false
```elixir
catelog = %Catelog{
  id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
  name: "Top.Hobbies",
  path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
}
Catelog.siblings(catelog) |> Repo.all
#  [
#    %Catelog{
#      id: "6c11f83f-3c3c-44bf-9940-8153c1f04de9",
#      name: "Top.Science",
#      path: "a9ae8f40-b016-4bf9-8224-e2755466e699"
#    },
#    %Catelog{
#      id: "570526aa-e2f3-49a7-870a-c150d3bf6ac9",
#      name: "Top.Collections",
#      path: "a9ae8f40-b016-4bf9-8224-e2755466e699"
#    }
#  ]
```

### `roots/0`
Return the roots query expression.
```elixir
Catelog.roots() |> Repo.all
#  [
#    %Catelog{
#      id: "a9ae8f40-b016-4bf9-8224-e2755466e699",
#      name: "Top",
#      path: ""
#    }
#  ]
```

## Contributing
First, set appropriate settings for test database.
```shell
export POSTGRES_USER=test_username POSTGRES_PASSWORD=test_password MIX_ENV=test
```
run test.
```elixir
mix test
```
