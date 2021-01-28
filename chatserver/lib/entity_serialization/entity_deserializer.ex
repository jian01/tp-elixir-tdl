defmodule EntityDeserializer do
  require SerializationConstants
  import TextMessage
  import ReceiptNotice
  import NewMessage

  def deserialize_message(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {id, sender_id, recipient_id, content, timestamp, type} = {json_parsed["id"], json_parsed["sender"],
    json_parsed["recipient"], json_parsed["content"], json_parsed["created_datetime"], "text"}
    case type do
      SerializationConstants.text_message_type ->
        %TextMessage{id: id, sender_id: sender_id, recipient_id: recipient_id,
                    text: content, timestamp: timestamp}
    end
  end

  def deserialize_notification(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {type, content, recipient} = {json_parsed["type"], json_parsed["content"], json_parsed["recipient"]}
    case type do
      SerializationConstants.new_message_type ->
        content_deserialized = deserialize_message(content)
        %NewMessage{message: content_deserialized, recipient: recipient}
      SerializationConstants.receipt_notice_type ->
        %ReceiptNotice{message_id: content, recipient: recipient}
    end
  end
end
