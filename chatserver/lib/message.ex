defmodule Message do
  defstruct [:id, :sender_id, :recipient_id, :content, :timestamp, :type]
end
