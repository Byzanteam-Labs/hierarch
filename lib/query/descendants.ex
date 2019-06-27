defmodule Hierarch.Query.Descendants do
  import Ecto.Query

  @doc """
  Return query expressions for descendants
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
  """
  def query(%{from: %{source: {_table_name, schema}}} = queryable) do
    path_column = schema.__hierarch__(:path_column)

    [pk_column] = schema.__schema__(:primary_key)

    uuids_query =
      from t in queryable,
      select: %{__ancestry__: fragment("text2ltree(replace(ltree2text(?), '-', '_')) || replace(text(?), '-', '_')", field(t, ^path_column), field(t, ^pk_column))}

    uuids_array_query =
      from t in subquery(uuids_query),
      select: %{__ltrees__: fragment("array_agg(?)", t.__ancestry__)}

    schema
    |> join(:cross, [], a in subquery(uuids_array_query))
    |> where([t, a], fragment("? @> ?", a.__ltrees__, field(t, ^path_column)))
  end
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
        where: fragment("? <@ ?", field(t, ^path_column), type(^descendants_path, ^path_column_field_type))
      )

    case with_self do
      true -> descendants_query |> or_where([t], field(t, ^pk_column) == ^value)
      _ -> descendants_query
    end
  end
end
