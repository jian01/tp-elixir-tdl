defmodule NewSerializer do
  import MessageSerializer
  def serialize_new(type, content, recipient) do
    case type do
      "new_message" ->
        unpacker = {&serialize_message/5, content}
        {function, {a,b,c,d,e}} = unpacker
        content = function.(a,b,c,d,e)
        {:ok, serialized} = JSON.encode(%{"type" => type, "content" => content, "recipient" => recipient})
        serialized
      "receipt_notice" ->
        content = Integer.to_string(content)
        {:ok, serialized} = JSON.encode(%{"type" => type, "content" => content, "recipient" => recipient})
        serialized
    end
  end

  def deserialize_new(data) do
    {:ok, json_parsed} = JSON.decode(data)
    {type, content, recipient} = {json_parsed["type"], json_parsed["content"], json_parsed["recipient"]}
    case type do
      "new_message" ->
        content_tuple = deserialize_message(content)
        {type, content_tuple, recipient}
      "receipt_notice" ->
        {content_tuple, _} = Integer.parse(data)
        {type, content_tuple, recipient}
    end
  end
end
