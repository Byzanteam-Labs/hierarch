defmodule Hierarch.Query.Descendants do
  import Ecto.Query

  @doc """
  Return query expressions for descendants
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
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
        where: fragment("? <@ ?", field(t, ^path_column), type(^descendants_path, ^path_column_field_type))
      )

    case with_self do
      true -> descendants_query |> or_where([t], field(t, ^pk_column) == ^value)
      _ -> descendants_query
    end
  end
end
