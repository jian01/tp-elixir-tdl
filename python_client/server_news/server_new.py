
class ServerNew:
    """
    A server new
    """

    @classmethod
    def factory(cls, name: str, content: str) -> 'ServerNew':
        """

        :param name: the name of the new
        :param content: the content of the new
        :return: a ServerNew object
        """
        types = {cls.__name__: cls for cls in ServerNew.__subclasses__()}
        if name == "new_message":
            return types['NewMessage'](content)
        raise AttributeError("Unknown type of new")