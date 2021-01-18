from messages.message import Message

class TextMessage(Message):
    """
    Message of text
    """

    def __init__(self, sender: int, recipient: int, text: str):
        """

        :param sender: the sender of the message
        :param recipient: recipient of the message
        :param text: the text of the message
        """
        self.content = text
        self.type = "text"
        super().__init__(sender, recipient)