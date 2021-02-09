defmodule EntityDeserializer do
  @moduledoc """
  Responsible for handling deserialization of model entities
  """
  require SerializationConstants
  import TextMessage
  import ReceiptNotice
  import NewMessage
  import NewNotification

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
    {type, content} = {json_parsed[SerializationConstants.notification_type_field],
                      json_parsed[SerializationConstants.notification_content_field]}
    case type do
      SerializationConstants.new_message_type ->
        content_deserialized = deserialize_message(content)
        %NewMessage{message: content_deserialized, recipient: content_deserialized.recipient_id}
      SerializationConstants.receipt_notice_type ->
        {:ok, content} = JSON.decode(content)
        %ReceiptNotice{message_id: content[SerializationConstants.message_id_field],
        recipient: content[SerializationConstants.notification_recipient_field]}
      SerializationConstants.new_notification_type ->
        {:ok, content} = JSON.decode(content)
        %NewNotification{id: content[SerializationConstants.new_notification_content_id],
        notification: deserialize_notification(content[SerializationConstants.new_notification_content_notif]),
        recipient: content[SerializationConstants.notification_recipient_field]}
    end
  end
end
