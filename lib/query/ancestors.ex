defmodule Hierarch.Query.Ancestors do
  import Ecto.Query

  @doc """
  Return query expressions for ancestors
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
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
