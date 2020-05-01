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
    condition = descendants_condition(struct)

    if Keyword.get(opts, :with_self, false) do
      from t in schema, where: ^condition, or_where: ^including_self_condition(struct)
    else
      from t in schema, where: ^condition
    end
  end

  defp descendants_condition(%schema{} = struct) do
    path = Hierarch.Util.struct_path(struct)

    [{_pk_column, value}] = Ecto.primary_key(struct)

    descendants_path = Hierarch.LTree.concat(path, value)

    path_column = schema.__hierarch__(:path_column)
    path_column_field_type = schema.__schema__(:type, path_column)

    dynamic(
      [p],
      fragment(
        "? <@ ?",
        field(p, ^path_column),
        type(^descendants_path, ^path_column_field_type)
      )
    )
  end

  defp including_self_condition(%_schema{} = struct) do
    [{pk_column, value}] = Ecto.primary_key(struct)

    dynamic([p], field(p, ^pk_column) == ^value)
  end
end
