import json

from messages.message import Message


class TextMessage(Message):
    """
    Message of text
    """
    SERIALIZER_NAME = "text"

    def __init__(self, sender: int, recipient: int, text: str):
        """

        :param sender: the sender of the message
        :param recipient: recipient of the message
        :param text: the text of the message
        """
        self.content = text
        super().__init__(sender, recipient)

    def serialize(self) -> str:
        """
        Serializes the message
        :return: a string of the serialized message
        """
        return json.dumps({"id": self.message_id,
                           "recipient": self.recipient,
                           "sender": self.sender,
                           "content": self.content,
                           "type": TextMessage.SERIALIZER_NAME,
                           "created_datetime": self.created_datetime.isoformat()})
