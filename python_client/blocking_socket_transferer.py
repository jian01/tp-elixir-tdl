import os
import socket
import select
from typing import Optional

DEFAULT_SOCKET_BUFFER_SIZE = 4096
OK_MESSAGE = "OK"
OK_MESSAGE_LEN = len(OK_MESSAGE.encode('utf-8'))
SIZE_NUMBER_SIZE = 20


class SocketClosed(Exception):
    pass


class BlockingSocketTransferer:
    def __init__(self, socket: socket):
        self.socket = socket
        self.poller = select.poll()
        self.poller.register(self.socket, select.POLLIN)

    def controlled_recv(self, size: int) -> bytes:
        data = self.socket.recv(size)
        if data == b'':
            raise SocketClosed
        return data

    @staticmethod
    def size_to_bytes_number(size: int) -> bytes:
        text = str(size)
        return text.zfill(SIZE_NUMBER_SIZE).encode('ascii')

    def receive_fixed_size(self, size) -> str:
        data = ""
        recv_size = 0
        while recv_size < size:
            new_data = self.controlled_recv(size - recv_size)
            recv_size += len(new_data)
            data += new_data.decode('ascii')
        return data

    def send_ok(self):
        self.send_plain_text(OK_MESSAGE)

    def receive_ok(self):
        text = self.receive_plain_text()
        assert text == OK_MESSAGE

    def receive_file_data(self, file):
        file_size = int(self.receive_fixed_size(SIZE_NUMBER_SIZE))
        self.send_ok()
        while file_size > 0:
            buffer = self.controlled_recv(DEFAULT_SOCKET_BUFFER_SIZE)
            file.write(buffer)
            file_size -= len(buffer)
        self.send_ok()

    def send_file(self, filename):
        file_size = os.stat(filename).st_size
        self.socket.sendall(self.size_to_bytes_number(file_size))
        self.receive_ok()
        with open(filename, "rb") as file:
            while file_size > 0:
                buffer = file.read(DEFAULT_SOCKET_BUFFER_SIZE)
                self.socket.sendall(buffer)
                file_size -= DEFAULT_SOCKET_BUFFER_SIZE
        self.receive_ok()

    def send_plain_text(self, text):
        encoded_text = text.encode('utf-8')
        self.socket.sendall(self.size_to_bytes_number(len(encoded_text)))
        self.socket.sendall(encoded_text)

    def receive_plain_text(self, timeout: Optional[int] = None) -> str:
        if timeout:
            events = self.poller.poll(timeout)
            if not events:
                raise TimeoutError
        size_to_recv = int(self.receive_fixed_size(SIZE_NUMBER_SIZE))
        result = ""
        recv_size = 0
        while recv_size < size_to_recv:
            new_data = self.controlled_recv(size_to_recv - recv_size)
            result += new_data.decode('utf-8')
            recv_size += len(new_data)
        return result

    def abort(self):
        self.send_plain_text("ABORT")
        self.close()

    def close(self):
        self.socket.shutdown(socket.SHUT_WR)
        self.socket.close()
