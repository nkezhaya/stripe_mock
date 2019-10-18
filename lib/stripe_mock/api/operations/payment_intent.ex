defmodule StripeMock.API.Operations.PaymentIntent do
  import Ecto.Query

  alias Ecto.Multi
  alias StripeMock.Repo
  alias StripeMock.API.{Charge, PaymentIntent}

  @preload [charges: [:card], payment_method: [:card, :source, token: [:card]]]

  def list_payment_intents() do
    PaymentIntent
    |> preload(^@preload)
    |> Repo.all()
  end

  def get_payment_intent(id) do
    PaymentIntent
    |> preload(^@preload)
    |> Repo.fetch(id)
    |> do_preloads()
  end

  def create_payment_intent(attrs) do
    %PaymentIntent{}
    |> PaymentIntent.changeset(attrs)
    |> Repo.insert()
    |> do_preloads()
  end

  def update_payment_intent(%PaymentIntent{} = payment_intent, attrs) do
    payment_intent
    |> PaymentIntent.changeset(attrs)
    |> Repo.update()
    |> do_preloads()
  end

  def confirm_payment_intent(%PaymentIntent{} = payment_intent) do
    Multi.new()
    |> Multi.insert(:charge, Charge.capture_changeset(%Charge{}, payment_intent))
    |> Multi.update(
      :payment_intent,
      PaymentIntent.status_changeset(payment_intent, "requires_action")
    )
    |> Repo.transaction()
    |> case do
      {:ok, %{payment_intent: payment_intent}} -> {:ok, payment_intent}
      {:error, _, value, _} -> {:error, value}
    end
    |> do_preloads()
  end

  def capture_payment_intent(%PaymentIntent{} = payment_intent) do
    query = where(Charge, [c], c.payment_intent_id == ^payment_intent.id)

    Multi.new()
    |> Multi.update_all(:charge, query, set: [captured: true])
    |> Multi.update(:payment_intent, PaymentIntent.status_changeset(payment_intent, "succeeded"))
    |> Repo.transaction()
    |> case do
      {:ok, %{payment_intent: payment_intent}} -> {:ok, payment_intent}
      {:error, _, value, _} -> {:error, value}
    end
    |> do_preloads()
  end

  defp do_preloads({:ok, payment_intent}) do
    {:ok, do_preloads(payment_intent)}
  end

  defp do_preloads(%PaymentIntent{} = payment_intent) do
    Repo.preload(payment_intent, @preload, force: true)
  end

  defp do_preloads([_ | _] = payment_intents) do
    Repo.preload(payment_intents, @preload, force: true)
  end

  defp do_preloads(arg), do: arg
end
