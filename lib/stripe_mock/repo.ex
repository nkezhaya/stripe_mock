defmodule StripeMock.Repo do
  @moduledoc """
  This is where we store everything. Obviously, don't call any of these
  functions yourself.

  State structure is:

      %{
        customer: %{
          "cus_123123" => %Customer{}
        }
      }
  """
  use GenServer
  import Ecto.Changeset
  alias Ecto.Changeset
  alias StripeMock.API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, [name: __MODULE__] ++ opts)
  end

  def all(schema), do: GenServer.call(pid(), {:all, schema})
  def insert(changeset), do: GenServer.call(pid(), {:save, changeset})
  def update(changeset), do: GenServer.call(pid(), {:save, changeset})
  def get(schema, id), do: GenServer.call(pid(), {:get, schema, id})

  def get!(schema, id) do
    case GenServer.call(pid(), {:get, schema, id}) do
      nil -> raise "No #{schema} found with id #{id}."
      record -> record
    end
  end

  def fetch(schema, id) do
    case get(schema, id) do
      nil -> {:error, :not_found}
      object -> {:ok, object}
    end
  end

  def delete(%Changeset{} = changeset) do
    changeset = put_change(changeset, :deleted, true)
    GenServer.call(pid(), {:save, changeset})
  end

  def delete(object), do: GenServer.call(pid(), {:save, %{object | deleted: true}})

  defp pid(), do: GenServer.whereis(__MODULE__)

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:all, schema}, _from, state) do
    case Map.get(state, type(schema)) do
      schemas when is_map(schemas) -> {:reply, Map.values(schemas), state}
      _ -> {:reply, [], state}
    end
  end

  @impl true
  def handle_call({:save, changeset}, _from, state) do
    case save(changeset, state) do
      {:ok, term, new_state} -> {:reply, {:ok, term}, new_state}
      {:error, _} = error -> {:reply, error, state}
    end
  end

  @impl true
  def handle_call({:get, schema, id}, _from, state) do
    object =
      with schemas when is_map(schemas) <- Map.get(state, type(schema)),
           object when is_map(object) <- Map.get(schemas, id) do
        object
      else
        _ -> nil
      end

    {:reply, object, state}
  end

  @spec save(Changeset.t(), map()) :: {:ok, any(), map()} | {:error, Changeset.t()}
  defp save(changeset, state) do
    changeset = change(changeset)

    changeset =
      case get_field(changeset, :id) do
        nil -> put_change(changeset, :id, generate_id(changeset.data))
        id when is_bitstring(id) -> changeset
      end

    changeset =
      cond do
        Map.has_key?(changeset.data, :created) ->
          case get_field(changeset, :created) do
            nil -> put_change(changeset, :created, :os.system_time(:seconds))
            _ -> changeset
          end

        true ->
          changeset
      end

    changeset =
      if Map.has_key?(changeset.data, :object) do
        put_change(changeset, :object, type(changeset.data))
      else
        changeset
      end

    changeset = set_client_ip(changeset)

    # Run through changed assocs and save
    {changeset, state} =
      Enum.reduce_while(changeset.changes, {changeset, state}, fn
        {key, %Changeset{} = assoc_change}, {changeset, state} ->
          case save(assoc_change, state) do
            {:ok, saved_assoc, new_state} ->
              changeset =
                changeset
                |> put_change(key, saved_assoc)
                |> put_change(String.to_atom("#{key}_id"), saved_assoc.id)

              {:cont, {changeset, new_state}}

            {:error, failed_assoc} ->
              changeset = put_change(changeset, key, failed_assoc)
              throw({:invalid_changeset, changeset})
          end

        _, acc ->
          {:cont, acc}
      end)

    if !changeset.valid? do
      throw({:invalid_changeset, changeset})
    end

    object = apply_changes(changeset)

    # Put the object into the new state
    type = type(object)

    type_map =
      case Map.get(state, type) do
        %{} = s -> s
        _ -> %{}
      end
      |> Map.put(object.id, object)

    new_state = Map.put(state, type, type_map)

    {:ok, object, new_state}
  catch
    {:invalid_changeset, changeset} ->
      {:error, changeset}
  end

  if Mix.env() == :test do
    defp set_client_ip(changeset) do
      if Map.has_key?(changeset.data, :client_ip) and is_nil(get_field(changeset, :client_ip)) do
        put_change(changeset, :client_ip, "0.0.0.0")
      else
        changeset
      end
    end
  else
    defp set_client_ip(changeset) do
      changeset
    end
  end

  defp generate_id(schema) do
    prefix(schema) <> "_" <> StripeMock.ID.generate()
  end

  def type(%{} = map), do: type(map.__struct__)
  def type(API.Card), do: :card
  def type(API.Charge), do: :charge
  def type(API.Customer), do: :customer
  def type(API.Refund), do: :refund
  def type(API.Token), do: :token

  def prefix(%API.Card{}), do: "card"
  def prefix(%API.Charge{}), do: "ch"
  def prefix(%API.Customer{}), do: "cus"
  def prefix(%API.Refund{}), do: "re"
  def prefix(%API.Token{}), do: "tok"
end
