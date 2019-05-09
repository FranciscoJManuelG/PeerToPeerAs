defmodule Peer do
    
    defp get_ip_port() do
        ip = Utils.param(:ip)
        port = Utils.param(:port)
        {String.to_charlist(ip),String.to_integer(port)}
    end

    defp do_operation(operation) do
        {ip,port} = get_ip_port()
        Client.connect(ip,port)
        Client.send(operation)
        Client.close()
    end

    defp hash(fich) do
        Enum.join(String.split(Kernel.inspect(
            [:crypto.hash(:sha256,File.read!(Utils.param(:files)<>fich))]))
        )
    end
    
    def connect() do
        do_operation("CONNECT")
        spawn_link(ServerPeer,:accept,[4000])
        :ok
    end

    def disconnect() do
        do_operation("DISCONNECT")
        down_local_server()
    end

    def offer(fich) do
        ruta = Utils.param(:files)<>fich
        case File.exists?(ruta) do
            true -> do_operation("OFFER "<>fich<>" "<>hash(fich))
            _ -> IO.puts("El fichero no existe")
        end
    end

    def want(fich) do
        do_operation("WANT "<>fich)
    end 
end