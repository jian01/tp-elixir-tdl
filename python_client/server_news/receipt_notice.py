import json
from typing import Tuple
from server_news.notification import Notification


class ReceiptNotice(Notification):
    """
    Notification indicating the message has been received
    """
    SERIALIZER_NAME = "receipt_notice"
    message_id: int

    @staticmethod
    def deserialize_content(content) -> Tuple:
        """
        Deserializes the message

        :param content: the message to deserialize
        :return: *args for initializing
        """
        dict_data = json.loads(content)
        return (dict_data["id"],
                dict_data["recipient"])

    def __init__(self, message_id: int, recipient_id: int):
        """

        :param message_id: the id of the message
        :param recipient_id: the recipient of the message
        """
        self.message_id = message_id
        self.recipient_id = recipient_id

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME,
                           "content": json.dumps({"id": self.message_id,
                                       "recipient": self.recipient_id})})
