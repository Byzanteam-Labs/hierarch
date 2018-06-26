defmodule Hierarch.LTree do
  @enforce_keys [:labels]
  defstruct [:labels]

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

  def dump(%Hierarch.LTree{} = value) do
    Enum.join(value.labels, @separotor)
  end
end
