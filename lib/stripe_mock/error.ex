defmodule StripeMock.Error do
  defstruct [:code, :message, :param, :type]

  @type t() :: %__MODULE__{
          code: atom(),
          message: String.t(),
          param: nil | map(),
          type: atom()
        }

  def unauthorized() do
    %__MODULE__{
      code: :unauthorized,
      message: "Unauthorized",
      param: nil,
      type: :unauthorized
    }
  end

  def http_status(%__MODULE__{code: :resource_missing, param: "id"}),
    do: 404

  def http_status(%__MODULE__{code: :resource_missing}),
    do: 400
end
