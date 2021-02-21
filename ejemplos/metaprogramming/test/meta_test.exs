defmodule MetaTest do
  use ExUnit.Case

  [{1, 2, 3}, {10, 20, 40}, {100, 200, 300}]
  |> Enum.each(fn {a, b, c} ->
    test "#{a} + #{b} = #{c}" do
      assert unquote(c) = unquote(a) + unquote(b)
    end
  end)

  [%TextMessage{id: 1, sender_id: 1, recipient_id: 2, text: "", timestamp: nil},
  %TextMessage{id: 2, sender_id: 1, recipient_id: 1, text: "", timestamp: nil},
  %TextMessage{id: 2, sender_id: 4, recipient_id: 7, text: "", timestamp: nil}]
  |> Enum.each(fn text_message ->
    test "Sender #{text_message.sender_id} != Recipient #{text_message.recipient_id} " do
      assert unquote(text_message.sender_id) != unquote(text_message.recipient_id)
    end
  end)
end
