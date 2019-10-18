defmodule StripeMockWeb.ViewHelpers do
  def as_map(struct, object \\ nil) do
    if is_bitstring(object) do
      Map.put(struct, :object, object)
    else
      struct
    end
    |> update_created()
    |> Map.delete(:__struct__)
    |> Map.delete(:__meta__)
    |> Map.put(:id, struct.stripe_id)
  end

  defp update_created(%{created: %{} = timestamp} = struct) do
    created =
      timestamp
      |> NaiveDateTime.to_erl()
      |> :calendar.datetime_to_gregorian_seconds()

    %{struct | created: created}
  end

  defp update_created(struct) do
    struct
  end
end
