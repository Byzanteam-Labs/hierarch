defmodule Hierarch.Query.Root do
  import Ecto.Query

  @doc """
  Return query expressions for the root
  """
  def query(%schema{} = struct) do
    condition = root_condition(struct)

    from schema, where: ^condition
  end

  defp root_condition(%_schema{} = struct) do
    path = Hierarch.Util.struct_path(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)
    root_id = Hierarch.LTree.root_id(path, value)

    dynamic([q], field(q, ^pk_column) == ^root_id)
  end
end
