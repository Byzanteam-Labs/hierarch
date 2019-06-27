defmodule Hierarch.Query.Descendants do
  import Ecto.Query

  @doc """
  Return query expressions for descendants
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
  """
  def query(%schema{} = struct, opts \\ []) do
    with_self = Keyword.get(opts, :with_self, false)

    path = Hierarch.Util.struct(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    path_column = schema.__hierarch__(:path_column)

    descendants_path = Hierarch.LTree.concat(path, value)

    path_column_field = dynamic([t], field(t, ^path_column))

    descendants_query =
      from(
        t in schema,
        where: fragment("? <@ ?", ^path_column_field, type(^descendants_path, ^path_column_field))
      )

    case with_self do
      true -> descendants_query |> or_where([t], field(t, ^pk_column) == ^value)
      _ -> descendants_query
    end
  end
end
