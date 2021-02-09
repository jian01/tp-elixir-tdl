defmodule SerializationConstants do
  @moduledoc """
  Constants used for serialization and deserialization
  """
  import Constants

  const :new_message_type, "new_message"
  const :receipt_notice_type, "receipt_notice"
  const :new_notification_type, "new_notification"
    const :notification_ack_type, "notification_ack"
  const :text_message_type, "text"
  const :notification_type_field, "type"
  const :notification_content_field, "content"
  const :notification_recipient_field, "recipient"
  const :message_id_field, "id"
  const :message_sender_field, "sender"
  const :message_recipient_field, "recipient"
  const :message_content_field, "content"
  const :message_timestamp_field, "created_datetime"
  const :message_type_field, "type"
  const :new_notification_content_id, "id"
  const :new_notification_content_notif, "notification"
end
