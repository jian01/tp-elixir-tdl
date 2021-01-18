defmodule MessageSerializer do
  def serialize_message(sender_id, recipient_id, content, timestamp) do
    JSON.encode(%{"sender" => sender_id,
                "recipient" => recipient_id,
                "content" => content,
                "created_datetime" => timestamp,
                "type" => "text"})
  end

  def deserialize_message(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {sender_id, recipient_id, text_message, timestamp, type} = {json_parsed["sender"],
    json_parsed["recipient"], json_parsed["content"], json_parsed["created_datetime"], "text"}
    {sender_id, recipient_id, text_message, timestamp, type}
  end
end
