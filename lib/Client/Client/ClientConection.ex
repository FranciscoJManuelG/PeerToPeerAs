defmodule ClientConection do 
    use GenServer

    def connect(ip, port) do
        case :gen_tcp.connect(ip,port,[:binary, packet: :line, active: false, reuseaddr: true]) do
            {:ok,socket} ->  {:ok,pid} = GenServer.start_link(__MODULE__, [socket])
                                Process.register(pid,:client)
                                :ok
            _ -> IO.puts("Servidor no disponible")
        end
    end

    def want_file(ip, port, file) do
        case :gen_tcp.connect(ip,port,[:binary, packet: :line, active: false, reuseaddr: true]) do
            {:ok,socket} ->  :gen_tcp.send(socket,"WANT "<>file<>"\n")
                                recfile = receive_file(socket,:gen_tcp.recv(socket,0,1000),"")
                                case recfile do
                                    "" -> IO.puts("Fichero no disponible")
                                        :gen_tcp.close(socket)
                                        :error
                                    _ -> File.write(Path.rootname(Utils.param(:downloaded))<>file,recfile)
                                        IO.puts(Path.rootname(Utils.param(:downloaded))<>file)
                                        :gen_tcp.close(socket)
                                        :ok
                                end
            _ -> IO.puts("Servidor no disponible")
        end
    end

    defp receive_file(_,{:ok,""},file),do: file
    defp receive_file(socket,{:ok,msg},file) do
        receive_file(socket,:gen_tcp.recv(socket,0,1000),file<>msg)
    end
    defp receive_file(_,_,file),do: file

    def send(message) do
        GenServer.cast(:client,{:send,message})
    end

    def close() do
        case Process.whereis(:client)!=nil do
            true -> GenServer.cast(:client,:close)
                    GenServer.stop(:client)
                    :ok
            _ -> :ok
        end
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
                 #GenServer.stop(:client)
        end
    end
end