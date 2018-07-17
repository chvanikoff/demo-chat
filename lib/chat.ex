defmodule Chat.Server do
  use GenServer

  def init(_args) do
    {:ok, %{messages: [], users: []}}
  end

  def handle_info({:message, message}, state) do
    broadcast(state.users, message)
    {:noreply, %{state | messages: [message | state.messages]}}
  end

  def handle_info({:join, user}, state) do
    message = %{from: "Chat", text: "#{user.name} joined"}
    broadcast(state.users, message)
    {:noreply, %{state | users: [user | state.users]}}
  end

  def handle_info({:leave, user}, state) do
    message = %{from: "Chat", text: "#{user.name} disconnected"}
    broadcast(state.users, message)
    {:noreply, %{state | users: state.users -- user}}
  end

  defp broadcast([], _message), do: :ok

  defp broadcast([user | users], message) do
    send(user.pid, message)
    broadcast(users, message)
  end
end
