import json
from datetime import datetime
import dateutil.parser


class Message:
    """
    Message interface
    """
    created_datetime: datetime
    sender: int
    recipient: int
    type: str
    content: str

    def __init__(self, sender: int, recipient: int):
        """

        :param sender: sender of the message
        :param recipient: recipient of the message
        """
        self.sender = sender
        self.recipient = recipient
        self.created_datetime = datetime.now()

    def serialize(self) -> str:
        """
        Serializes the message
        :return: a string of the serialized message
        """
        return json.dumps({"recipient": self.recipient,
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
        object = cls(data_dict['sender'], data_dict['recipient'])
        object.content = data_dict['content']
        object.type = data_dict['type']
        object.created_datetime = dateutil.parser.parse(data_dict['created_datetime'])
        return object
