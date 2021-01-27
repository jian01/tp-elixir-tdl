from server_news.notification import Notification
from messages.message import Message
import json

class NewMessage(Notification):
    """
    New message new
    """
    SERIALIZER_NAME = "new_message"
    message: Message

    def __init__(self, content: str, recipient_id: int):
        """

        :param content: the content of the new message serialized
        :param recipient_id: recipient of the message, ignored
        """
        self.message = Message.deserialize(content)

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME, "content": self.message.serialize(),
                           "recipient": self.message.recipient})