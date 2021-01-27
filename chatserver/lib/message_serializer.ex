defmodule MessageSerializer do
  def serialize_message(id, sender_id, recipient_id, content, timestamp) do
    {:ok, serialized} = JSON.encode(%{"id" => id,
    "sender" => sender_id,
    "recipient" => recipient_id,
    "content" => content,
    "created_datetime" => timestamp,
    "type" => "text"})

    serialized
  end

  def deserialize_message(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {id, sender_id, recipient_id, text_message, timestamp, type} = {json_parsed["id"], json_parsed["sender"],
    json_parsed["recipient"], json_parsed["content"], json_parsed["created_datetime"], "text"}
    {id, sender_id, recipient_id, text_message, timestamp, type}
  end
end
