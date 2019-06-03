defmodule StripeMock.Pagination.Page do
  @moduledoc """
  Defines a `Page` type for passing data to the views.
  """

  @enforce_keys [:has_more, :data]
  defstruct [:has_more, :data]

  @type t() :: %__MODULE__{
          has_more: boolean(),
          data: list()
        }
end
