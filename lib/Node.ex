defmodule Node do
    
    def start() do
        {:ok,list} = File.read("directories.conf")
        ip = Enum.at(list,3)
        Client.connect(@initial_state.host,@initial_state.port)
        Client.send("CONNECT")
        Client.close()
    end

    # def offer(fich) do
    #     Client
    # end
    
end