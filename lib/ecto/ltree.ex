defmodule Hierarch.Ecto.LTree do
  @behaviour Ecto.Type

  def type, do: :ltree

  @doc """
  Casts the value to Hierarch.LTree
  """
  def cast(value) when is_list(value) do
    {:ok, Hierarch.LTree.cast(value)}
  end
  def cast(value) when is_binary(value) do
    {:ok, Hierarch.LTree.cast(value)}
  end
  def cast(_), do: :error

  @doc """
  Dump Hierarch.LTree value to String
  """
  def dump(%Hierarch.LTree{} = value) do
    {:ok, Hierarch.LTree.dump(value)}
  end
  def dump(_), do: :error

  @doc """
  Load String to Hierarch.LTree
  """
  def load(value) do
    {:ok, Hierarch.LTree.cast(value)}
  end
end
