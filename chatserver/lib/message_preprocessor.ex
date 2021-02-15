import TextMessage

defprotocol MessagePreprocessor do
  @doc """
  Preprocess Message before send
  """

  def preprocess(message)
end

defimpl MessagePreprocessor, for: TextMessage do
  def preprocess(message) do
    message
  end
end
