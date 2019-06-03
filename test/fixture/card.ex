defmodule StripeMock.CardFixture do
  def valid_card() do
    %{
      number: "4242424242424242",
      exp_month: "12",
      exp_year: "2020",
      cvc: "123"
    }
  end
end
