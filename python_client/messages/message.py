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

    def __init__(self, sender: int, recipient: int, message_id: Optional[int] = None):
        """

        :param message_id: the id of the message
        :param sender: sender of the message
        :param recipient: recipient of the message
        """
        if not message_id:
            self.message_id = Message.MESSAGE_ID_COUNT
            Message.MESSAGE_ID_COUNT += 1
        else:
            self.message_id = message_id
        self.sender = sender
        self.recipient = recipient
        self.created_datetime = datetime.now()

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
        msg = types[data_dict['type']](data_dict['sender'], data_dict['recipient'], data_dict['id'])
        msg.content = data_dict['content']
        msg.created_datetime = dateutil.parser.parse(data_dict['created_datetime'])
        return msg
