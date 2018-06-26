defmodule Hierarch.Postgrex.Extensions.LTree do
  @behaviour Postgrex.Extension
  # It can be memory efficient to copy the decoded binary because a
  # reference counted binary that points to a larger binary will be passed
  # to the decode/4 callback. Copying the binary can allow the larger
  # binary to be garbage collected sooner if the copy is going to be kept
  # for a longer period of time. See `:binary.copy/1` for more
  # information.
  def init(opts) do
    Keyword.get(opts, :decode_copy, :copy)
  end
  # Use this extension when `type` from %Postgrex.TypeInfo{} is "ltree"
  def matching(_state), do: [type: "ltree"]
  # Use the text format, "ltree" does not have a binary format.
  def format(_state), do: :text
  # Use quoted expression to encode a string that is the same as
  # postgresql's ltree text format. The quoted expression should contain
  # clauses that match those of a `case` or `fn`. Encoding matches on the
  # value and returns encoded `iodata()`. The first 4 bytes in the
  # `iodata()` must be the byte size of the rest of the encoded data, as a
  # signed 32bit big endian integer.
  def encode(_state) do
    quote do
      bin when is_binary(bin) ->
        [<<byte_size(bin) :: signed-size(32)>> | bin]
    end
  end
  # Use quoted expression to decode the data to a string. Decoding matches
  # on an encoded binary with the same signed 32bit big endian integer
  # length header.
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
