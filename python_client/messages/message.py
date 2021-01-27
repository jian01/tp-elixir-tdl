import json
from typing import Optional
from datetime import datetime

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
    type: str
    content: str

    def __init__(self, sender: int, recipient: int, message_id: Optional[int]=None):
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

    def serialize(self) -> str:
        """
        Serializes the message
        :return: a string of the serialized message
        """
        return json.dumps({"id": self.message_id,
                           "recipient": self.recipient,
                           "sender": self.sender,
                           "content": self.content,
                           "type": self.type,
                           "created_datetime": self.created_datetime.isoformat()})

    @classmethod
    def deserialize(cls, serialized: str) -> 'Message':
        """
        Deserializes any message
        :param serialized: serialized message
        :return: a Message object
        """
        data_dict = json.loads(serialized)
        object = cls(data_dict['sender'], data_dict['recipient'], data_dict['id'])
        object.content = data_dict['content']
        object.type = data_dict['type']
        object.created_datetime = dateutil.parser.parse(data_dict['created_datetime'])
        return object
