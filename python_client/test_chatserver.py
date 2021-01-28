import unittest
from multiprocessing import Process, Barrier
from time import sleep
from typing import List, NoReturn

from chat_server_connector import ChatServerConnector
from messages.message import Message
from messages.text_message import TextMessage
from server_news.new_message import NewMessage
from server_news.receipt_notice import ReceiptNotice


class SimpleTestClient:
    """
    Client for testing
    """

    def __init__(self, client_id: int,
                 messages_to_send: List[Message], messages_to_expect: List[Message]):
        """

        :param client_id: the client id for instantiation
        :param messages_to_send: the messages to send to the clients
        :param messages_to_expect: messages that are expected to be received
        """
        self.client_id = client_id
        self.messages_to_send = messages_to_send
        self.messages_to_expect = messages_to_expect
        self.messages_received = []
        self.messages_with_receipt_notice = set()

    def expecting_more_news(self) -> bool:
        """
        Indicates whether we are not expecting any more news
        :return: a boolean
        """
        all_w_receipt_notice = set([m.message_id for m in self.messages_to_send]) == self.messages_with_receipt_notice
        all_messages_received = set([m.serialize() for m in self.messages_received]) == set(
            [m.serialize() for m in self.messages_to_expect])
        return all_w_receipt_notice and all_messages_received

    def __call__(self) -> NoReturn:
        """
        Runs the process
        """
        connector = ChatServerConnector('localhost', 6500, self.client_id)
        for message in self.messages_to_send:
            connector.send_message(message)
        while self.expecting_more_news():
            news = connector.get_news()
            for new in news:
                if isinstance(new, NewMessage):
                    self.messages_received.append(new.message)
                elif isinstance(new, ReceiptNotice):
                    self.messages_with_receipt_notice.update([new.message_id])
                else:
                    continue
        exit(0)


class TestChatServer(unittest.TestCase):

    def test_simple_receive_message(self):
        def jorgito():
            connector = ChatServerConnector('localhost', 6500, 8)
            connector.send_message(TextMessage(8, 7, "Hola don pepito"))
            news = [new for new in connector.get_news() if isinstance(new, NewMessage)]
            while not news:
                news = [new for new in connector.get_news() if isinstance(new, NewMessage)]
            assert len(news) == 1
            assert news[0].message.sender == 7
            assert news[0].message.content == "Hola jorgito"
            exit(0)

        def pepito():
            connector = ChatServerConnector('localhost', 6500, 7)
            connector.send_message(TextMessage(7, 8, "Hola jorgito"))
            news = [new for new in connector.get_news() if isinstance(new, NewMessage)]
            while not news:
                news = [new for new in connector.get_news() if isinstance(new, NewMessage)]
            assert len(news) == 1
            assert news[0].message.sender == 8
            assert news[0].message.content == "Hola don pepito"
            exit(0)

        p_jorgito = Process(target=jorgito)
        p_pepito = Process(target=pepito)
        p_jorgito.start()
        p_pepito.start()
        p_jorgito.join()
        p_pepito.join()
        self.assertEqual(p_pepito.exitcode, 0)
        self.assertEqual(p_jorgito.exitcode, 0)

    def test_simple_receipt_message(self):
        def escritor():
            connector = ChatServerConnector('localhost', 6500, 6)
            message = TextMessage(6, 5, "Hola don pepito")
            connector.send_message(message)
            news = connector.get_news()
            while not news:
                news = connector.get_news()
            assert len(news) == 1
            assert news[0].message_id == message.message_id
            exit(0)

        def receptor():
            connector = ChatServerConnector('localhost', 6500, 5)
            news = connector.get_news()
            while not news:
                news = connector.get_news()
            assert len(news) == 1
            assert news[0].message.sender == 6
            exit(0)

        p1 = Process(target=escritor)
        p2 = Process(target=receptor)
        p1.start()
        p2.start()
        p1.join()
        p2.join()
        self.assertEqual(p1.exitcode, 0)
        self.assertEqual(p2.exitcode, 0)

    def test_multiple_clients(self):
        messages_to_send = [TextMessage(i, j, "Hola %d" % j) for i in range(4)
                            for j in range(4) if i != j] + [
                               TextMessage(1, 3, "Todo bien perri?"),
                               TextMessage(3, 1, "See todo bien"),
                               TextMessage(1, 3, "Me alegro")
                           ]
        cl1 = SimpleTestClient(0, [m for m in messages_to_send if m.sender == 0],
                               [m for m in messages_to_send if m.recipient == 0])
        cl2 = SimpleTestClient(1, [m for m in messages_to_send if m.sender == 1],
                               [m for m in messages_to_send if m.recipient == 1])
        cl3 = SimpleTestClient(2, [m for m in messages_to_send if m.sender == 2],
                               [m for m in messages_to_send if m.recipient == 2])
        cl4 = SimpleTestClient(3, [m for m in messages_to_send if m.sender == 3],
                               [m for m in messages_to_send if m.recipient == 3])
        p1 = Process(target=cl1)
        p2 = Process(target=cl2)
        p3 = Process(target=cl3)
        p4 = Process(target=cl4)
        p1.start()
        p2.start()
        p3.start()
        p4.start()
        p1.join()
        p2.join()
        p3.join()
        p4.join()
        self.assertEqual(p1.exitcode, 0)
        self.assertEqual(p2.exitcode, 0)
        self.assertEqual(p3.exitcode, 0)
        self.assertEqual(p4.exitcode, 0)


if __name__ == '__main__':
    unittest.main()
