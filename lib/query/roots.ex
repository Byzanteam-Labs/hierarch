defmodule Hierarch.Query.Roots do
  import Ecto.Query

  @doc """
  Return query expressions for roots
  """
  def query(schema) do
    roots_path = ""

    from(
      t in schema,
      where: field(t, ^schema.__hierarch__(:path_column)) == ^roots_path
    )
  end
end
