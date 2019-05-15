defmodule InterfaceOperations do
    alias ServerOperations, as: ServerI

    def start() do
		ServerI.start()
    end
    
    def isNodeUp(name) do
		GenServer.call(:server, {:nodeIsUp, name})
	end

	def isAdmin(ip) do
		ip == "127.0.0.1"
    end
    
end