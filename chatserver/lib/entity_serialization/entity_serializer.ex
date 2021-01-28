require SerializationConstants
import TextMessage
import ReceiptNotice
import NewMessage

defprotocol EntitySerializer do
  def serialize(entity)
end

defimpl EntitySerializer, for: ReceiptNotice do
  def serialize(notification) do
    {:ok, serialized} = JSON.encode(%{"type" => SerializationConstants.receipt_notice_type, "content" => notification.message_id,
                                    "recipient" => notification.recipient})
    serialized
  end
end

defimpl EntitySerializer, for: NewMessage do
  def serialize(notification) do
    content = EntitySerializer.serialize(notification.message)
    {:ok, serialized} = JSON.encode(%{"type" => SerializationConstants.new_message_type, "content" => content,
                                    "recipient" => notification.recipient})
    serialized
  end
end

defimpl EntitySerializer, for: TextMessage do
  def serialize(message) do
    {:ok, serialized} = JSON.encode(%{"id" => message.id,
    "sender" => message.sender_id,
    "recipient" => message.recipient_id,
    "content" => message.text,
    "created_datetime" => message.timestamp,
    "type" => SerializationConstants.text_message_type})

    serialized
  end
end
