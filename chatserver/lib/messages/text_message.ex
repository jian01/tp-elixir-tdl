defmodule TextMessage do
  @moduledoc """
  Text message
  """
  defstruct [:id, :sender_id, :recipient_id, :text, :timestamp]
end
