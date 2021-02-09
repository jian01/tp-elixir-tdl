require SerializationConstants
import TextMessage
import ReceiptNotice
import NewMessage
import NewNotification

defprotocol EntitySerializer do
  @doc """
  Serializes to string a model entity
  """
  def serialize(entity)
end

defimpl EntitySerializer, for: ReceiptNotice do
  def serialize(notification) do
    {:ok, serialized} = JSON.encode(%{SerializationConstants.notification_type_field => SerializationConstants.receipt_notice_type,
                                    SerializationConstants.notification_content_field => notification.message_id,
                                    SerializationConstants.notification_recipient_field => notification.recipient})
    serialized
  end
end

defimpl EntitySerializer, for: NewMessage do
  def serialize(notification) do
    content = EntitySerializer.serialize(notification.message)
    {:ok, serialized} = JSON.encode(%{SerializationConstants.notification_type_field => SerializationConstants.new_message_type,
                                    SerializationConstants.notification_content_field => content,
                                    SerializationConstants.notification_recipient_field => notification.recipient})
    serialized
  end
end

defimpl EntitySerializer, for: NewNotification do
  def serialize(notification) do
    {:ok, content} = JSON.encode(%{SerializationConstants.new_notification_content_id => notification.id,
                                SerializationConstants.new_notification_content_notif => EntitySerializer.serialize(notification.notification)})
    {:ok, serialized} = JSON.encode(%{SerializationConstants.notification_type_field => SerializationConstants.new_notification_type,
                                    SerializationConstants.notification_content_field => content,
                                    SerializationConstants.notification_recipient_field => notification.recipient})
    serialized
  end
end

defimpl EntitySerializer, for: TextMessage do
  def serialize(message) do
    {:ok, serialized} = JSON.encode(%{SerializationConstants.message_id_field => message.id,
                                    SerializationConstants.message_sender_field => message.sender_id,
                                    SerializationConstants.message_recipient_field => message.recipient_id,
                                    SerializationConstants.message_content_field => message.text,
                                    SerializationConstants.message_timestamp_field => message.timestamp,
                                    SerializationConstants.message_type_field => SerializationConstants.text_message_type})

    serialized
  end
end
