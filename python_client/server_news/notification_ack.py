import json
from typing import Tuple
from server_news.notification import Notification


class NotificationAck(Notification):
    """
    Notification indicating a notification is acked
    """
    SERIALIZER_NAME = "notification_ack"
    notification_id: int

    @staticmethod
    def deserialize_content(content) -> Tuple:
        """
        Deserializes the message

        :param content: the message to deserialize
        :return: *args for initializing
        """
        notif_id = json.loads(content)
        return (notif_id,)

    def __init__(self, notification_id: int):
        """

        :param notification_id: the id of the acked notification
        """
        self.notification_id = notification_id

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME,
                           "content": json.dumps(self.notification_id)})
