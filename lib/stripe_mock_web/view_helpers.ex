defmodule StripeMockWeb.ViewHelpers do
  def as_map(struct) do
    struct
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
  end
end
