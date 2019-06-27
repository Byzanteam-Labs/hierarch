defmodule Hierarch.Query.Children do
  import Ecto.Query

  @doc """
  Return query expressions for children
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
  """
  def query(%schema{} = struct, opts \\ []) do
    with_self = Keyword.get(opts, :with_self, false)

    path = Hierarch.Util.struct_path(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    children_path = Hierarch.LTree.concat(path, value)

    children_query = from(
      t in schema,
      where: field(t, ^schema.__hierarch__(:path_column)) == ^children_path
    )

    case with_self do
      true -> children_query |> or_where([t], field(t, ^pk_column) == ^value)
      _ -> children_query
    end
  end
end
