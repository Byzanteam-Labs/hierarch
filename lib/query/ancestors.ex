defmodule Hierarch.Query.Ancestors do
  import Ecto.Query

  @doc """
  Return query expressions for ancestors
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
  """
  def query(%{from: %{source: {_table_name, schema}}} = queryable) do
    path_column = schema.__hierarch__(:path_column)

    [pk_column] = schema.__schema__(:primary_key)

    uuids_query =
      from t in queryable,
      select: %{__uuid__: fragment("regexp_split_to_table(replace(ltree2text(?), '_', '-'), '\\.')", field(t, ^path_column))}

    uuids_array_query =
      from t in subquery(uuids_query),
      where: not is_nil(t.__uuid__),
      or_where: t.__uuid__ != ^"",
      select: %{__uuids__: fragment("array_agg(cast(? as uuid))", t.__uuid__)}

    schema
    |> join(:cross, [], a in subquery(uuids_array_query))
    |> where([t, a], field(t, ^pk_column) in a.__uuids__)
  end
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
