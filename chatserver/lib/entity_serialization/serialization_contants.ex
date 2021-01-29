defmodule SerializationConstants do
  @moduledoc """
  Constants used for serialization and deserialization
  """
  import Constants

  const :new_message_type, "new_message"
  const :receipt_notice_type, "receipt_notice"
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
end