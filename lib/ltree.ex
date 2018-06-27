defmodule Hierarch.LTree do
  @enforce_keys [:labels]
  defstruct [:labels]
  alias Hierarch.LTree

  @separotor "."

  def cast(labels) when is_binary(labels) do
    labels
    |> String.split(@separotor)
    |> Enum.reject(fn(label) -> label == "" end)
    |> cast()
  end

  def cast(labels) when is_list(labels) do
    struct(__MODULE__, labels: labels)
  end

  def cast(_), do: :error

  def dump(%LTree{} = value) do
    Enum.join(value.labels, @separotor)
  end

  @doc """
  Return the parent of the current LTree
  ## Examples

      iex> ltree = %LTree{labels: ["Top", "Science"]}
      iex> parent = LTree.parent(ltree)
      iex> parent.labels
      ["Top"]
  """
  def parent(%LTree{} = value) do
    value.labels
    |> List.delete_at(-1)
    |> LTree.cast()
  end
end
