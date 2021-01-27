defmodule MessageSerializer do
  import Message

  def serialize_message(message) do
    {:ok, serialized} = JSON.encode(%{"id" => message.id,
    "sender" => message.sender_id,
    "recipient" => message.recipient_id,
    "content" => message.content,
    "created_datetime" => message.timestamp,
    "type" => message.type})

    serialized
  end

  def deserialize_message(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {id, sender_id, recipient_id, content, timestamp, type} = {json_parsed["id"], json_parsed["sender"],
    json_parsed["recipient"], json_parsed["content"], json_parsed["created_datetime"], "text"}
    %Message{id: id, sender_id: sender_id, recipient_id: recipient_id,
            content: content, timestamp: timestamp, type: type}
  end
end
