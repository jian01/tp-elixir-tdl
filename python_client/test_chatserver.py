import unittest
from multiprocessing import Process, Barrier
from chat_server_connector import ChatServerConnector
from messages.text_message import TextMessage
from server_news.new_message import NewMessage
from messages.message import Message
from time import sleep

class TestDiskMessagePipeline(unittest.TestCase):

    def test_simple_receive_message(self):
        def jorgito(barrera):
            connector = ChatServerConnector('localhost', 6500, 2)
            barrera.wait()
            connector.send_message(TextMessage(2, 1, "Hola don pepito"))
            barrera.wait()
            sleep(1)
            news = connector.get_news()
            news = [new for new in news if isinstance(new, NewMessage)]
            del connector
            try:
                assert len(news) == 1
                assert news[0].message.sender == 1
                assert news[0].message.content == "Hola jorgito"
                exit(0)
            except AssertionError as e:
                raise e

        def pepito(barrera):
            connector = ChatServerConnector('localhost', 6500, 1)
            barrera.wait()
            connector.send_message(TextMessage(1, 2, "Hola jorgito"))
            barrera.wait()
            sleep(1)
            news = connector.get_news()
            news = [new for new in news if isinstance(new, NewMessage)]
            del connector
            try:
                assert len(news) == 1
                assert news[0].message.sender == 2
                assert news[0].message.content == "Hola don pepito"
                exit(0)
            except AssertionError as e:
                raise e

        barrera = Barrier(2)
        p_jorgito = Process(target=jorgito, args=(barrera,))
        p_pepito = Process(target=pepito, args=(barrera,))
        p_jorgito.start()
        p_pepito.start()
        p_jorgito.join()
        p_pepito.join()
        self.assertEqual(p_pepito.exitcode, 0)
        self.assertEqual(p_jorgito.exitcode, 0)

    def test_simple_receipt_message(self):
        def escritor(barrera):
            connector = ChatServerConnector('localhost', 6500, 2)
            barrera.wait()
            message = TextMessage(2, 1, "Hola don pepito")
            connector.send_message(message)
            barrera.wait()
            sleep(1)
            barrera.wait()
            sleep(1)
            news = connector.get_news()
            del connector
            try:
                assert len(news) == 1
                assert news[0].message_id == message.message_id
                exit(0)
            except AssertionError as e:
                raise e

        def receptor(barrera):
            connector = ChatServerConnector('localhost', 6500, 1)
            barrera.wait()
            barrera.wait()
            sleep(1)
            news = connector.get_news()
            del connector
            try:
                assert len(news) == 1
                assert news[0].message.sender == 2
            except AssertionError as e:
                raise e
            barrera.wait()
            exit(0)

        barrera = Barrier(2)
        p1 = Process(target=escritor, args=(barrera,))
        p2 = Process(target=receptor, args=(barrera,))
        p1.start()
        p2.start()
        p1.join()
        p2.join()
        self.assertEqual(p1.exitcode, 0)
        self.assertEqual(p2.exitcode, 0)

    def test_message_serialize_deserialize(self):
        message = TextMessage(2, 1, "Hola don pepito")
        serialized = message.serialize()
        message_out = Message.deserialize(serialized)
        self.assertEqual(message.message_id, message_out.message_id)


if __name__ == '__main__':
    unittest.main()