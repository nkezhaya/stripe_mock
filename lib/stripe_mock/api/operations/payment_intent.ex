defmodule StripeMock.API.Operations.PaymentIntent do
  import Ecto.Query

  alias StripeMock.Repo
  alias StripeMock.API.{Charge, PaymentIntent}

  @preload [payment_method: [:card, :source, token: [:card]]]

  def list_payment_intents() do
    PaymentIntent
    |> preload(^@preload)
    |> Repo.all()
  end

  def get_payment_intent(id) do
    PaymentIntent
    |> preload(^@preload)
    |> Repo.fetch(id)
    |> preload_payment_method()
  end

  def create_payment_intent(attrs) do
    %PaymentIntent{}
    |> PaymentIntent.changeset(attrs)
    |> Repo.insert()
    |> preload_payment_method()
  end

  def update_payment_intent(%PaymentIntent{} = payment_intent, attrs) do
    payment_intent
    |> PaymentIntent.changeset(attrs)
    |> Repo.update()
    |> preload_payment_method()
  end

  def confirm_payment_intent(%PaymentIntent{} = payment_intent) do
    payment_intent
    |> PaymentIntent.status_changeset("requires_capture")
    |> Repo.update()
    |> preload_payment_method()
  end

  def capture_payment_intent(%PaymentIntent{} = payment_intent) do
    charge =
      %Charge{}
      |> Charge.capture_changeset(payment_intent)
      |> Repo.insert!()

    payment_intent
    |> PaymentIntent.capture_changeset(charge)
    |> Repo.update!()
    |> preload_payment_method()
  end

  defp preload_payment_method({:ok, payment_intent}) do
    {:ok, preload_payment_method(payment_intent)}
  end

  defp preload_payment_method(%PaymentIntent{} = payment_intent) do
    Repo.preload(payment_intent, @preload)
  end

  defp preload_payment_method([_ | _] = payment_intents) do
    Repo.preload(payment_intents, @preload)
  end

  defp preload_payment_method(arg), do: arg
end
