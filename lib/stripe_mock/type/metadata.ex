defmodule StripeMock.Type.Metadata do
  @behaviour Ecto.Type

  def type(), do: :map

  def cast(nil), do: {:ok, %{}}
  def cast(""), do: {:ok, %{}}

  def cast(metadata) when is_map(metadata) do
    value =
      for {k, v} <- metadata,
          is_bitstring(k) and String.length(k) <= 40,
          is_bitstring(v) and String.length(v) <= 500,
          into: %{},
          do: {k, v}

    {:ok, value}
  end

  def cast(_), do: :error

  def dump(value) when is_map(value), do: {:ok, value}
  def dump(_), do: :error

  def load(value) when is_map(value), do: {:ok, value}
  def load(_), do: :error
end
