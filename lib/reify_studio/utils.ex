defmodule ReifyStudio.Utils do
  @moduledoc """
  General utility functions for the ReifyStudio application.
  """

  @doc """
  Generates a short random identifier (8 hex characters).

  This is NOT a UUID - it's a lightweight 4-byte random string suitable for
  response tracking or other cases where collision probability is acceptable.
  For true UUIDs, use `Ecto.UUID.generate/0`.
  """
  def short_id do
    :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
  end
end
