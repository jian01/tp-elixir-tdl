defmodule NotificationSerializer do
  import MessageSerializer
  import Notification

  def serialize_notification(notification) do
    case notification.type do
      "new_message" ->
        content = serialize_message(notification.content)
        {:ok, serialized} = JSON.encode(%{"type" => notification.type, "content" => content,
                                        "recipient" => notification.recipient})
        serialized
      "receipt_notice" ->
        content = Integer.to_string(notification.content)
        {:ok, serialized} = JSON.encode(%{"type" => notification.type, "content" => content,
                                        "recipient" => notification.recipient})
        serialized
    end
  end

  def deserialize_notification(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {type, content, recipient} = {json_parsed["type"], json_parsed["content"], json_parsed["recipient"]}
    case type do
      "new_message" ->
        content_deserialized = deserialize_message(content)
        %Notification{type: type, content: content_deserialized, recipient: recipient}
      "receipt_notice" ->
        {content_deserialized, _} = Integer.parse(content)
        %Notification{type: type, content: content_deserialized, recipient: recipient}
    end
  end
end
