defmodule Hierarch.Query.Root do
  import Ecto.Query

  @doc """
  Return query expressions for the root
  """
  def query(%schema{} = struct) do
    path = Hierarch.Util.struct(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    root_id =
      struct
      |> Hierarch.Util.struct_path()
      |> Hierarch.LTree.root_id(path, value)

    from(
      t in schema,
      where: field(t, ^pk_column) == ^root_id
    )
  end
end
