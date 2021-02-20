import json
from abc import abstractmethod
from datetime import datetime
from typing import Optional

import dateutil.parser


class Message:
    MESSAGE_ID_COUNT = 1
    """
    Message interface
    """
    message_id: int
    created_datetime: datetime
    sender: int
    recipient: int
    content: str

    def __init__(self, sender: int, recipient: int,
                 message_id: Optional[int] = None,
                 creation_datetime: Optional[datetime] = None):
        """

        :param message_id: the id of the message
        :param sender: sender of the message
        :param recipient: recipient of the message
        :param creation_datetime: the created datetime
        """
        if not message_id:
            self.message_id = Message.MESSAGE_ID_COUNT
            Message.MESSAGE_ID_COUNT += 1
        else:
            self.message_id = message_id
        self.sender = sender
        self.recipient = recipient
        self.created_datetime = creation_datetime
        if not creation_datetime:
            self.created_datetime = datetime.now()

    @staticmethod
    def deserialize_content(content):
        """
        Deserializes the content of the message if needed

        :param content: the content to deserialize
        :return: the object
        """
        return content

    @abstractmethod
    def serialize(self) -> str:
        """
        Serializes the message
        :return: a string of the serialized message
        """

    @classmethod
    def deserialize(cls, serialized: str) -> 'Message':
        """
        Deserializes any message
        :param serialized: serialized message
        :return: a Message object
        """
        types = {cls.SERIALIZER_NAME: cls for cls in Message.__subclasses__()}
        data_dict = json.loads(serialized)
        content = types[data_dict['type']].deserialize_content(data_dict['content'])
        msg = types[data_dict['type']](data_dict['sender'], data_dict['recipient'],
                                       content, data_dict['id'],
                                       dateutil.parser.parse(data_dict['created_datetime']))
        return msg
