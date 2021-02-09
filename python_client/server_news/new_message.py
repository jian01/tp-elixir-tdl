import json
from typing import Tuple
from messages.message import Message
from server_news.notification import Notification


class NewMessage(Notification):
    """
    New message new
    """
    SERIALIZER_NAME = "new_message"
    message: Message

    @staticmethod
    def deserialize_content(content) -> Tuple:
        """
        Deserializes the message

        :param content: the message to deserialize
        :return: a Message object and the recipient
        """
        message = Message.deserialize(content)
        return message, message.recipient

    def __init__(self, message: Message, recipient_id: int):
        """

        :param message: the message
        :param recipient_id: recipient of the message
        """
        self.message = message
        self.recipient_id = recipient_id

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME,
                           "content": self.message.serialize()})
