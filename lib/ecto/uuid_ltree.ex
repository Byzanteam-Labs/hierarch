defmodule Hierarch.Ecto.UUIDLTree do
  use Ecto.Type

  @dash "-"
  @underline "_"

  def type, do: :ltree

  @doc """
  Casts the value to UUID string label
  """
  def cast(label) when is_binary(label) do
    {:ok, to_human(label)}
  end

  def cast(_), do: :error

  @doc """
  Convert UUIDD string value to LTree label String
  """
  def dump(label) when is_binary(label) do
    {:ok, to_db(label)}
  end

  def dump(_), do: :error

  @doc """
  Load String to UUID string label
  """
  def load(label) when is_binary(label) do
    {:ok, to_human(label)}
  end

  def load(_), do: {:ok, ""}

  defp to_human(value) do
    String.replace(value, @underline, @dash)
  end

  defp to_db(value) do
    String.replace(value, @dash, @underline)
  end
end
