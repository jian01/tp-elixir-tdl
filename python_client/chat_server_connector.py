import json
import socket
from typing import NoReturn, List

from blocking_socket_transferer import BlockingSocketTransferer
from messages.message import Message
from server_news.new_message import NewMessage
from server_news.notification import Notification
from server_news.receipt_notice import ReceiptNotice

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
        new_message = NewMessage(message, message.recipient)
        self.send_notification(new_message)

    def get_news(self) -> List[Notification]:
        """
        Gets all server news

        :return: a list of server news
        """
        self.blocking_socket_transferer.send_plain_text(GET_NEWS_KEYWORD)
        news_data = json.loads(self.blocking_socket_transferer.receive_plain_text())
        news = [Notification.deserialize(new_data).notification for new_data in news_data]
        for new in news:
            if isinstance(new, NewMessage):
                notification = ReceiptNotice(new.message.message_id, new.message.sender)
                self.send_notification(notification)
        return news

    def send_notification(self, notif: Notification) -> NoReturn:
        """
        Sends a notification to the server

        :param notif: the notification to send to the server
        """
        data = notif.serialize()
        self.blocking_socket_transferer.send_plain_text(data)

    def __del__(self) -> NoReturn:
        """
        Closes the socket
        """
        self.blocking_socket_transferer.close()
