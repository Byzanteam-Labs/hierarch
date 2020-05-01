defmodule Hierarch.Query.Roots do
  import Ecto.Query

  @roots_path ""

  @doc """
  Return query expressions for roots
  """
  def query(schema) do
    condition = roots_condition(schema)

    from schema, where: ^condition
  end

  def roots_condition(schema) do
    path_column = schema.__hierarch__(:path_column)

    dynamic([q], field(q, ^path_column) == ^@roots_path)
  end
end
