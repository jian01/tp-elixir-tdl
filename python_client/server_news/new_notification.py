import json
from typing import Tuple, Any
from messages.message import Message
from server_news.notification import Notification


class NewNotification(Notification):
    """
    New message new
    """
    SERIALIZER_NAME = "new_notification"
    notif_id: int
    notification: Notification

    @staticmethod
    def deserialize_content(content) -> Tuple[int, Notification]:
        """
        Deserializes the message

        :param content: the message to deserialize
        :return: *args for initializing
        """
        dict_data = json.loads(content)
        return (dict_data["id"],
                Notification.deserialize(dict_data["notification"]))

    def __init__(self, notif_id: int,
                 notification: Notification,
                 recipient_id: int):
        """

        :param notif_id: the notification id
        :param notification: the new notification
        :param recipient_id: recipient of the notification
        """
        self.notification = notification
        self.notif_id = notif_id
        self.recipient_id = recipient_id

    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        return json.dumps({"type": self.SERIALIZER_NAME,
                           "content": json.dumps({"id": self.notif_id,
                                                  "notification": self.notification.serialize()}),
                           "recipient": self.recipient_id})
