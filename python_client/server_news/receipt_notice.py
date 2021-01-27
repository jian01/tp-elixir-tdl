from server_news.notification import Notification
import json

class ReceiptNotice(Notification):
    """
    Notification indicating the message has been received
    """
    SERIALIZER_NAME = "receipt_notice"
    message_id: int

    def __init__(self, content: str, recipient_id: int):
        """

        :param content: the id of the message as str
        :param recipient_id: the recipient of the message
        """
        self.message_id = int(content)
        self.receipient_id = recipient_id

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME, "content": str(self.message_id),
                           "recipient": self.receipient_id})