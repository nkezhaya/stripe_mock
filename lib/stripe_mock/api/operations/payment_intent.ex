defmodule StripeMock.API.Operations.PaymentIntent do
  alias StripeMock.Repo
  alias StripeMock.API.{Charge, PaymentIntent}

  def list_payment_intents() do
    Repo.all(PaymentIntent)
  end

  def get_payment_intent(id), do: Repo.fetch(PaymentIntent, id)
  def get_payment_intent!(id), do: Repo.get!(PaymentIntent, id)

  def create_payment_intent(attrs \\ %{}) do
    %PaymentIntent{}
    |> PaymentIntent.changeset(attrs)
    |> Repo.insert()
  end

  def update_payment_intent(%PaymentIntent{} = payment_intent, attrs) do
    payment_intent
    |> PaymentIntent.changeset(attrs)
    |> Repo.update()
  end

  def confirm_payment_intent(%PaymentIntent{} = payment_intent) do
    payment_intent
    |> PaymentIntent.status_changeset("requires_capture")
    |> Repo.update()
  end

  def capture_payment_intent(%PaymentIntent{} = payment_intent) do
    charge =
      %Charge{}
      |> Charge.payment_intent_changeset(payment_intent)
      |> Repo.insert!()

    payment_intent
    |> PaymentIntent.capture_changeset(charge)
    |> Repo.update!()
  end
end
