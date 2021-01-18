from time import sleep
from chat_server_connector import ChatServerConnector
from messages.text_message import TextMessage
from server_news.new_message import NewMessage

SIZE_NUMBER_SIZE = 20
MY_ID = 2

connector = ChatServerConnector('localhost', 6500, MY_ID)
sleep(3)
connector.send_message(TextMessage(MY_ID, 1, "Hola don pepito"))
sleep(3)
news = connector.get_news()
for new in news:
    if isinstance(new, NewMessage):
        message = new.message
        print("[%s] from %d: %s" % (message.created_datetime, message.sender, message.content))
