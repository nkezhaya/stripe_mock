defmodule StripeMockWeb.SourceView do
  use StripeMockWeb, :view

  def render("show.json", %{source: source}) do
    case source.id do
      "card_" <> _ -> render_one(source, StripeMockWeb.CardView, "card.json")
      _ -> raise "Weird ID"
    end
  end
end
