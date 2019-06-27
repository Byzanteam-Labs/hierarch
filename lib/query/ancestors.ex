defmodule Hierarch.Query.Ancestors do
  import Ecto.Query

  @doc """
  Return query expressions for ancestors of a query

  ```elixir
  import Ecto.Query

  query = from t in Catelog, where: [..]

  query
  |> Hierarch.Query.Ancestors.query()
  |> Repo.all
  """
  def query(%{from: %{source: {_table_name, schema}}} = queryable) do
    path_column = schema.__hierarch__(:path_column)

    [pk_column] = schema.__schema__(:primary_key)

    uuids_query =
      from(t in queryable,
        select: %{
          __uuid__:
            fragment(
              "regexp_split_to_table(replace(ltree2text(?), '_', '-'), '\\.')",
              field(t, ^path_column)
            )
        }
      )

    uuids_array_query =
      from(t in subquery(uuids_query),
        where: not is_nil(t.__uuid__),
        or_where: t.__uuid__ != ^"",
        select: %{__uuids__: fragment("array_agg(cast(? as uuid))", t.__uuid__)}
      )

    schema
    |> join(:cross, [], a in subquery(uuids_array_query))
    |> where([t, a], field(t, ^pk_column) in a.__uuids__)
  end

  @doc """
  Return query expressions for ancestors
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.

  ```elixir
  %Catelog{
    id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
    name: "Top.Hobbies",
    path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
  }
  |> Hierarch.Query.Ancestors.query()
  |> Repo.all

  # or

  %Catelog{
    id: "06a84054-8827-42c2-9b75-25ed75e6d5f8",
    name: "Top.Hobbies",
    path: "a9ae8f40-b016-4bf9-8224-e2755466e699",
  }
  |> Catelog.ancestors()
  |> Repo.all
  """
  def query(%schema{} = struct, opts \\ []) do
    with_self = Keyword.get(opts, :with_self, false)

    path = Hierarch.Util.struct_path(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    ancestor_ids =
      case with_self do
        true -> Hierarch.LTree.split(path) ++ [value]
        _ -> Hierarch.LTree.split(path)
      end

    from(
      t in schema,
      where: field(t, ^pk_column) in ^ancestor_ids
    )
  end
end
