from server_news.server_new import ServerNew
from messages.message import Message

class NewMessage(ServerNew):
    """
    New message new
    """
    message: Message

    def __init__(self, content: str):
        """

        :param content: the content of the new message serialized
        """
        self.message = Message.deserialize(content)