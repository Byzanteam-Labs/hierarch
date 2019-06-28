defmodule Hierarch.Postgrex.Extensions.LQuery do
  @behaviour Postgrex.Extension

  def init(opts) do
    Keyword.get(opts, :decode_copy, :copy)
  end

  def matching(_state), do: [type: "lquery"]

  def format(_state), do: :text

  def encode(_state) do
    quote do
      bin when is_binary(bin) ->
        [<<byte_size(bin)::signed-size(32)>> | bin]
    end
  end

  def decode(:reference) do
    quote do
      <<len::signed-size(32), bin::binary-size(len)>> ->
        bin
    end
  end

  def decode(:copy) do
    quote do
      <<len::signed-size(32), bin::binary-size(len)>> ->
        :binary.copy(bin)
    end
  end
end
