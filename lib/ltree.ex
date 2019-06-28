defmodule Hierarch.LTree do
  @separator "."

  @doc """
  Return the parent_id of the given ltree path
  ## Examples

      iex> LTree.parent_id("Top")
      "Top"
      iex> LTree.parent_id("")
      nil
      iex> LTree.parent_id("")
      nil
      iex> LTree.parent_id(nil)
      nil
  """
  def parent_id(nil), do: nil
  def parent_id(""), do: nil

  def parent_id(path) when is_binary(path) do
    path
    |> split
    |> List.last()
  end

  @doc """
  Return parent path of the given path
  """
  def parent_path(path) do
    path
    |> split
    |> List.delete_at(-1)
    |> join
  end

  @doc """
  Return the root_id of the given ltree path
  ## Examples

      iex> LTree.root_id("Top", "Science")
      "Top"
      iex> LTree.root_id("", "Top")
      "Top"
      iex> LTree.root_id(nil, "Top")
      "Top"

  ## Options:
    * `current_pk` - the primary key of the current schema
  """
  def root_id(nil, current_pk), do: current_pk
  def root_id("", current_pk), do: current_pk

  def root_id(path, _current_pk) do
    path
    |> split
    |> List.first()
  end

  @doc """
  Split string path into an arry
  """
  def split(nil), do: []
  def split(""), do: []

  def split(path) when is_binary(path) do
    String.split(path, @separator)
  end

  @doc """
  Join list into a string path
  """
  def join([]), do: nil

  def join(list) when is_list(list) do
    Enum.join(list, @separator)
  end

  @doc """
  Concat path or string
  """
  def concat(one, another) do
    [one, another]
    |> Enum.reject(fn label -> label == nil or label == "" end)
    |> join()
  end
end
