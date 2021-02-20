#!/usr/bin/env python3
"""Script for Tkinter GUI chat client."""
from threading import Thread
import tkinter
import tkinter.simpledialog
import argparse
from chat_server_connector import ChatServerConnector
from messages.text_message import TextMessage
from server_news.new_message import NewMessage
from server_news.receipt_notice import ReceiptNotice
from functools import partial
from multiprocessing import Process, Pipe

MY_MESSAGE_AUTHOR = "USTED"

def keep_update(ip, port, id, news_sender, messages_receiver):
    csc = ChatServerConnector(host=args.ip, port=args.port, id=args.id)
    while True:
        news = csc.get_news()
        if news:
            news_sender.send(news)
        if messages_receiver.poll(0.1):
            message = messages_receiver.recv()
            csc.send_message(message)

def update_status():
    global current_conversations
    global received_messages
    if news_receiver.poll(0.1):
        news = news_receiver.recv()
        for new in [n for n in news if isinstance(n, NewMessage) or isinstance(n, ReceiptNotice)]:
            if isinstance(new, NewMessage):
                message = new.message
                current_conversations[message.sender].append((message.created_datetime, contacts[message.sender],
                                                                message.content, message.message_id))
            else:
                received_messages.update([new.message_id])

def update_window(tklist, chat_id, _):
    global current_conversations
    global received_messages
    update_status()
    tklist.delete(0, 'end')
    for message in sorted(current_conversations[chat_id], key=lambda x: x[0], reverse=True):
        tklist.insert(-1, "%s %s - %s: %s" % (("✔️✔️" if message[3] in received_messages else "✔️"),
                                              message[0].isoformat(), message[1], message[2])) #fecha, autor, mensaje
    tklist.yview_moveto(0)

def send_message(tklist, recipient, my_msg, _):
    update_status()
    text = my_msg.get()
    my_msg.set("")
    message = TextMessage(my_id, recipient, text)
    current_conversations[recipient].append((message.created_datetime, MY_MESSAGE_AUTHOR,
                                             text, message.message_id))
    messages_sender.send(message)
    tklist.delete(0, 'end')
    for message in sorted(current_conversations[recipient], key=lambda x: x[0], reverse=True):
        tklist.insert(-1, "%s %s - %s: %s" % (("✔✔️️" if message[3] in received_messages else "✔️"),
                                              message[0].isoformat(), message[1], message[2])) #fecha, autor, mensaje
    tklist.yview_moveto(0)

def chat_with_contact(window, contact_id: int):
    global current_conversations
    if contact_id not in current_conversations:
        current_conversations[contact_id] = []
    update_status()
    if window:
        window.destroy()
    window = tkinter.Tk()
    messages_frame = tkinter.Frame(window)
    window.title("Chatter - Conversation with %d" % contact_id)
    scrollbar = tkinter.Scrollbar(messages_frame)
    msg_list = tkinter.Listbox(messages_frame, height=15, width=50, yscrollcommand=scrollbar.set)
    back_button = tkinter.Button(window, text="Ir atras", command=partial(see_all_contacts, window))
    back_button.pack()
    scrollbar.pack(side=tkinter.RIGHT, fill=tkinter.Y)
    msg_list.pack(side=tkinter.LEFT, fill=tkinter.BOTH)
    msg_list.pack()
    my_msg = tkinter.StringVar()  # For the messages to be sent.
    my_msg.set("")
    messages_frame.pack()
    entry_field = tkinter.Entry(window, textvariable=my_msg, width=50)
    entry_field.bind("<Return>", partial(send_message, msg_list, contact_id, my_msg))
    entry_field.bind("<Alt_L>", partial(update_window, msg_list, contact_id))
    entry_field.pack()
    for message in sorted(current_conversations[contact_id], key=lambda x: x[0], reverse=True):
        msg_list.insert(-1, "%s %s - %s: %s" % (("✔✔️️" if message[3] in received_messages else "✔️"),
                                              message[0].isoformat(), message[1], message[2]))  # fecha, autor, mensaje
    return window

def add_contact(window):
    update_status()
    global contacts
    contact_id =  tkinter.simpledialog.askinteger("Ingrese id de amiwi", "Id")
    nombre = tkinter.simpledialog.askstring("Ingrese nombre de amiwi", "Nombre")
    contacts[contact_id] = nombre
    see_all_contacts(window)
    tkinter.mainloop()

def see_all_contacts(window):
    update_status()
    global contacts
    if window:
        window.destroy()
    window = tkinter.Tk()
    back = tkinter.Frame(window, width=200, height=200)
    back.pack()
    window.title("Chatter %d" % my_id)
    for con_id, name in contacts.items():
        con_but = tkinter.Button(window, text="Hablar con %s" % name, command=partial(chat_with_contact, window, con_id))
        con_but.pack()
    back_button = tkinter.Button(window, text="Add contact", command=partial(add_contact, window))
    back_button.pack()
    return window

parser = argparse.ArgumentParser(description='Run client')
parser.add_argument('port', type=int,
                    help='port to connect')
parser.add_argument('ip', type=str,
                    help='ip to connect')
parser.add_argument('id', type=int,
                    help='your id')
args = parser.parse_args()
my_id = args.id

news_receiver, news_sender = Pipe()
messages_receiver, messages_sender = Pipe()
p = Process(target=partial(keep_update, args.ip, args.port, args.id, news_sender, messages_receiver))
p.start()
contacts = {}
current_conversations = {}
received_messages = set()
see_all_contacts(None)
tkinter.mainloop()  # Starts GUI execution.
