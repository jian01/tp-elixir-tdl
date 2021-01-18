from typing import NoReturn, List
from blocking_socket_transferer import BlockingSocketTransferer
from messages.message import Message
from server_news.server_new import ServerNew
import json
import socket

GET_NEWS_KEYWORD = "GET_NEWS"

class ChatServerConnector:
    """
    Connector to the chat server
    """

    def __init__(self, host: str, port: int, id: int):
        """

        :param host: host of the chat server
        :param port: port of the chat server
        :param id: the id of the client
        """
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
        sock.sendall(BlockingSocketTransferer.size_to_bytes_number(id))
        self.blocking_socket_transferer = BlockingSocketTransferer(sock)
        self.id = id

    def send_message(self, message: Message) -> NoReturn:
        """
        Sends a message

        :param message: the message to send
        """
        self.blocking_socket_transferer.send_plain_text(message.serialize())

    def get_news(self) -> List[ServerNew]:
        """
        Gets all server news

        :return: a list of server news
        """
        self.blocking_socket_transferer.send_plain_text(GET_NEWS_KEYWORD)
        news_data = json.loads(self.blocking_socket_transferer.receive_plain_text())
        news = [ServerNew.factory(new_data['type'], new_data['content']) for new_data in news_data]
        return news
