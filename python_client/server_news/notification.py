import json
from typing import Tuple
from abc import abstractmethod


class Notification:
    """
    A notification either from the server or from the client
    """

    @staticmethod
    def deserialize_content(content) -> Tuple:
        """
        Deserializes the content of the notification if needed

        :param content: the content to deserialize
        :return: a tuple to unpack in the constructor
        """
        return (content, )

    @classmethod
    def deserialize(cls, serialized: str) -> 'Notification':
        """

        Deserializes any notification
        :param serialized: serialized message
        :return: a Notification object
        """
        data_dict = json.loads(serialized)
        types = {cls.SERIALIZER_NAME: cls for cls in Notification.__subclasses__()}
        content = types[data_dict['type']].deserialize_content(data_dict['content'])
        return types[data_dict['type']](*content)

    @abstractmethod
    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        pass
