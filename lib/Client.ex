defmodule Client do
    def send(ip,port,message) do
        {:ok,socket} = :gen_tcp.connect(ip,port,[:binary, active: false])
        loop(socket,message,100000)
        #:gen_tcp.close(socket)
    end

    defp loop(_,_,0),do: :ok
    defp loop(socket,message,n) do 
        :gen_tcp.send(socket,message)
        {:ok, data} = :gen_tcp.recv(socket, 0)
        IO.puts(data)
        loop(socket,message,n-1)
    end

end