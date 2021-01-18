import unittest
from multiprocessing import Process, Barrier
from chat_server_connector import ChatServerConnector
from messages.text_message import TextMessage
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
            try:
                assert len(news) == 1
                assert news[0].message.sender == 1
                assert news[0].message.content == "Hola jorgito"
                return 0
            except AssertionError:
                return 1

        def pepito(barrera):
            connector = ChatServerConnector('localhost', 6500, 1)
            barrera.wait()
            connector.send_message(TextMessage(1, 2, "Hola jorgito"))
            barrera.wait()
            sleep(1)
            news = connector.get_news()
            try:
                assert len(news) == 1
                assert news[0].message.sender == 1
                assert news[0].message.content == "Hola don pepito"
                return 0
            except AssertionError:
                return 1

        barrera = Barrier(2)
        p_jorgito = Process(target=jorgito, args=(barrera,))
        p_pepito = Process(target=pepito, args=(barrera,))
        p_jorgito.start()
        p_pepito.start()
        p_jorgito.join()
        p_pepito.join()
        self.assertEqual(p_pepito.exitcode, 0)
        self.assertEqual(p_jorgito.exitcode, 0)

if __name__ == '__main__':
    unittest.main()