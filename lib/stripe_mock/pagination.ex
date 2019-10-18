defmodule StripeMock.Pagination do
  @moduledoc """
  Handles the Stripe-esque pagination.
  """

  alias __MODULE__.Page

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      def render_page(conn, page, view, template) do
        %{
          object: "list",
          url: "/v1/customers",
          has_more: page.has_more,
          data: render_many(page.data, view, template, conn: conn)
        }
      end
    end
  end

  @spec paginate(list(), map()) :: Page.t()
  def paginate(objects, params \\ %{}) do
    limit = get_limit(params)

    objects =
      case params["starting_after"] do
        nil -> objects
        starting_after -> Enum.drop_while(objects, &(&1.id != starting_after))
      end

    %Page{data: Enum.take(objects, limit), has_more: length(objects) > limit}
  end

  @default_limit 10
  defp get_limit(%{"limit" => limit}) do
    case Integer.parse(limit) do
      {limit, ""} -> max(limit, 1)
      _ -> @default_limit
    end
  end

  defp get_limit(_params), do: @default_limit
end
