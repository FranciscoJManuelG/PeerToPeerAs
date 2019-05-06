defmodule Client do
    use GenServer

    def connect(),do: connect('127.0.0.1',5000)
    def connect(ip,port) do
        {:ok,socket} = :gen_tcp.connect(ip,port,[:binary, packet: :line, active: false, reuseaddr: true])
        {:ok,pid} = GenServer.start_link(__MODULE__, [socket])
        Process.register(pid,:client)
        :ok
    end

    def send(message) do
        GenServer.cast(:client,{:send,Kernel.inspect(message)})
    end

    def close() do
        GenServer.cast(:client,:close)
        GenServer.stop(:client)
        :ok
    end

    def send_stringlist([],_),do: :ok
    def send_stringlist([""|tl], socket),do: send_stringlist(tl,socket)
    def send_stringlist([message|tl], socket) do
        :gen_tcp.send(socket,message<>"\n")
        {:ok, data} = :gen_tcp.recv(socket, 0)
        IO.puts(data)
        send_stringlist(tl,socket)
    end

    def send_stringlist(_,_),do: :error

    def init(socket),do: {:ok,socket}

    def handle_cast({:send,message},[socket]) do
        send_stringlist(String.split(message,"\n"),socket)
        {:noreply,[socket]}
    end

    def handle_cast(:close,[socket]) do
        :gen_tcp.close(socket)
        {:noreply,[]}
    end
end