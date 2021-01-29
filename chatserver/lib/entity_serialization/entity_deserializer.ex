defmodule EntityDeserializer do
  @moduledoc """
  Responsible for handling deserialization of model entities
  """
  require SerializationConstants
  import TextMessage
  import ReceiptNotice
  import NewMessage

  @doc """
  Deserializes a message serialized with the EntitySerializer protocol
  """
  def deserialize_message(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {id, sender_id, recipient_id, content, timestamp, type} = {json_parsed[SerializationConstants.message_id_field],
                                                              json_parsed[SerializationConstants.message_sender_field],
                                                              json_parsed[SerializationConstants.message_recipient_field],
                                                              json_parsed[SerializationConstants.message_content_field],
                                                              json_parsed[SerializationConstants.message_timestamp_field],
                                                              json_parsed[SerializationConstants.message_type_field]}
    case type do
      SerializationConstants.text_message_type ->
        %TextMessage{id: id, sender_id: sender_id, recipient_id: recipient_id,
                    text: content, timestamp: timestamp}
    end
  end

  @doc """
  Deserializes a notification serialized with the EntitySerializer protocol
  """
  def deserialize_notification(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {type, content, recipient} = {json_parsed[SerializationConstants.notification_type_field],
                                  json_parsed[SerializationConstants.notification_content_field],
                                  json_parsed[SerializationConstants.notification_recipient_field]}
    case type do
      SerializationConstants.new_message_type ->
        content_deserialized = deserialize_message(content)
        %NewMessage{message: content_deserialized, recipient: recipient}
      SerializationConstants.receipt_notice_type ->
        %ReceiptNotice{message_id: content, recipient: recipient}
    end
  end
end
