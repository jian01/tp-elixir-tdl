from abc import abstractmethod


class Notification:
    """
    A notification either from the server or from the client
    """

    @classmethod
    def factory(cls, name: str, content: str, recipient_id: int) -> 'Notification':
        """

        :param name: the name of the new
        :param content: the content of the new
        :param recipient_id: the recipient of the new
        :return: a ServerNew object
        """
        types = {cls.__name__: cls for cls in Notification.__subclasses__()}
        if name == types['NewMessage'].SERIALIZER_NAME:
            return types['NewMessage'](content, recipient_id)
        elif name == types['ReceiptNotice'].SERIALIZER_NAME:
            return types['ReceiptNotice'](content, recipient_id)
        raise AttributeError("Unknown type of new")

    @abstractmethod
    def serialize(self) -> str:
        """
        Serializes the notification for sending it to the server
        :return: a string with the serialized notification
        """
        pass