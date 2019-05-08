defmodule Peer do
    
    def get_ip_port() do
        {:ok,list} = File.read("directories.conf")
        ip = Enum.at(list,3)
        port = Enum.at(list,4)
        {String.to_charlist(ip),String.to_integer(port)}
    end

    def do_operation(operation) do
        {ip,port} = get_ip_port()
        Client.connect(ip,port)
        Client.send(operation)
        Client.close()
    end
    
    def connect() do
        do_operation("CONNECT")
    end

    def offer(fich) do
        do_operation("OFFER "<>fich)
    end

    def want(fich) do
        do_operation("WANT "<>fich)
    end  
end