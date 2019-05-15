defmodule AdminPeer do
    
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
        case spawn_link(ServerPeer,:accept,[4000]) do
            {:ok,pid} ->  Process.register(pid, :serverpeer)
            _ ->"No se pudo iniciar el servidor interno"
            end
        :ok
    end

    def disconnect() do
        do_operation("DISCONNECT")
        # Process.exit(:serverpeer, :normal)
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

    def view() do
        do_operation("VIEW")
    end

    def add_nodeM(id,ip) do
        do_operation("ADD NODEM "<>id<>" "<>ip)
    end

    def remove_nodeM(id) do
        do_operation("REMOVE NODEM "<>id)
    end

    def give_me_file(ip,fich,hash) do
        Client.want(String.to_charlist(ip),4000,fich)
        if check_hash(fich,hash) do
            IO.puts("Fichero descargado correctamente.")
        else
            File.rm(Utils.param(:downloaded)<>fich)
            IO.puts("El hash es incorrecto. Descarga abortada.")
        end
    end

    defp check_hash(fich,hash) do
        expected_hash = hash(fich)
        actual_hash = hash
        if expected_hash == actual_hash do
            true
        else
            false
        end
    end
end