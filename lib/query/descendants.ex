defmodule Hierarch.Query.Descendants do
  import Ecto.Query

  @doc """
  Return query expressions for descendants of a query

  ```elixir
  import Ecto.Query

  query = from t in Catelog, where: [..]

  query
  |> Hierarch.Query.Descendants.query()
  |> Repo.all
  """
  def query(%{from: %{source: {_table_name, schema}}} = queryable) do
    path_column = schema.__hierarch__(:path_column)

    [pk_column] = schema.__schema__(:primary_key)

    uuids_query =
      from(t in queryable,
        select: %{
          __ancestry__:
            fragment(
              "? || replace(text(?), '-', '_')",
              field(t, ^path_column),
              field(t, ^pk_column)
            )
        }
      )

    uuids_array_query =
      from(t in subquery(uuids_query),
        select: %{__ltrees__: fragment("array_agg(?)", t.__ancestry__)}
      )

    schema
    |> join(:cross, [], a in subquery(uuids_array_query))
    |> where([t, a], fragment("? @> ?", a.__ltrees__, field(t, ^path_column)))
  end

  @doc """
  Return query expressions for descendants
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.


  ```elixir
  %Catelog{
    id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
    name: "Top.Hobbies",
    path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
  }
  |> Hierarch.Query.Descendants.query()
  |> Repo.all

  # or

  %Catelog{
    id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
    name: "Top.Hobbies",
    path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
  }
  |> Catelog.descendants()
  |> Repo.all
  ```
  """

  def query(%schema{} = struct, opts \\ []) do
    with_self = Keyword.get(opts, :with_self, false)

    path = Hierarch.Util.struct_path(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    descendants_path = Hierarch.LTree.concat(path, value)

    path_column = schema.__hierarch__(:path_column)
    path_column_field_type = schema.__schema__(:type, path_column)

    descendants_query =
      from(
        t in schema,
        where:
          fragment(
            "? <@ ?",
            field(t, ^path_column),
            type(^descendants_path, ^path_column_field_type)
          )
      )

    case with_self do
      true -> descendants_query |> or_where([t], field(t, ^pk_column) == ^value)
      _ -> descendants_query
    end
  end
end
