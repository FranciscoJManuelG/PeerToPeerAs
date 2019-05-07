defmodule ClientConection do 

    def connect(ip, port) do
        {:ok,socket} = :gen_tcp.connect(ip,port,[:binary, packet: :line, active: false, reuseaddr: true])
        {:ok,pid} = GenServer.start_link(__MODULE__, [socket])
        Process.register(pid,:client)
        :ok
    end

    def send(message) do
        GenServer.cast(:client,{:send,message})
    end

    def close() do
        GenServer.cast(:client,:close)
        GenServer.stop(:client)
        :ok
    end

    @impl true
    def init(socket),do: {:ok,socket}

    @impl true
    def handle_cast({:send,message},[socket]) do
        send_stringlist(String.split(message,"\n"),socket)
        {:noreply,[socket]}
    end

    @impl true
    def handle_cast(:close,[socket]) do
        :gen_tcp.close(socket)
        {:noreply,[]}
    end

    def send_stringlist([],_),do: :ok
    def send_stringlist([""|tl], socket),do: send_stringlist(tl,socket)
    def send_stringlist([message|tl], socket) do
        :gen_tcp.send(socket,message<>"\n")
        case :gen_tcp.recv(socket, 0) do
            {:ok, data} ->  IO.puts(data)
                            send_stringlist(tl,socket)
            _ -> IO.puts("Error con el servidor. Conexion cerrada")
                 GenServer.stop(:client)
        end
        
    end
end