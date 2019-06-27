defmodule Hierarch.Query.Siblings do
  import Ecto.Query

  @doc """
  Return query expressions for siblings
  ## Options

    * `:with_self` - when true to include itself. Defaults to false.
  """
  def query(%schema{} = struct, opts \\ []) do
    with_self = Keyword.get(opts, :with_self, false)

    [{pk_column, value}] = Ecto.primary_key(struct)

    path = Hierarch.Util.struct_path(struct)
    parent_path = path

    siblings_with_self_query =
      from(
        t in schema,
        where: field(t, ^schema.__hierarch__(:path_column)) == ^parent_path
      )

    case with_self do
      true ->
        siblings_with_self_query

      _ ->
        siblings_with_self_query |> where([t], field(t, ^pk_column) != ^value)
    end
  end
end
