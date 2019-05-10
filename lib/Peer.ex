defmodule Peer do
    
    # defp get_ip_port() do
    #     ip = Utils.param(:ip)
    #     port = Utils.param(:port)
    #     {String.to_charlist(ip),String.to_integer(port)}
    # end

    # defp do_operation(operation) do
    #     {ip,port} = get_ip_port()
    #     Client.connect(ip,port)
    #     Client.send(operation)
    #     Client.close()
    # end

    defp do_operation(operation,ip,port) do 
        Client.connect(ip,port)
        Client.send(operation)
        Client.close()
    end

    defp hash(fich) do
        Enum.join(String.split(Kernel.inspect(
            [:crypto.hash(:sha256,File.read!(Utils.param(:files)<>fich))]))
        )
    end
    
    def connect(ip,port) do
        do_operation("CONNECT",ip,port)
        case spawn_link(ServerPeer,:accept,[4000]) do
            {:ok,pid} ->  Process.register(pid, :serverpeer)
            _ ->"No se pudo iniciar el servidor interno"
            end
        :ok
    end

    def disconnect(ip,port) do
        do_operation("DISCONNECT",ip,port)
        Process.exit(:serverpeer, :normal)
    end

    def offer(fich,ip,port) do
        ruta = Utils.param(:files)<>fich
        case File.exists?(ruta) do
            true -> do_operation("OFFER "<>fich<>" "<>hash(fich),ip,port)
            _ -> IO.puts("El fichero no existe")
        end
    end

    def want(fich,ip,port) do
        do_operation("WANT "<>fich,ip,port)
    end 

    def give_me_file(ip,fich) do
        Client.want(String.to_charlist(ip),4000,fich)
    end
end