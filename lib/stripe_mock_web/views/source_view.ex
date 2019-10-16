defmodule StripeMockWeb.SourceView do
  use StripeMockWeb, :view

  def render("show.json", %{source: source}) do
    render_one(source, StripeMockWeb.CardView, "card.json")
  end
end
