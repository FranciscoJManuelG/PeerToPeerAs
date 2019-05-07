defmodule Interface do

	def execute(orden, ip) do
		if Process.whereis(:server) != nil do
			#Si es una ip admin ejecuta execute_admin, si no, ejecuta execute_client
			if ClientInterface.isAdmin(ip) do
				Interface.execute_admin(String.split(orden))
			else 
				node = ClientInterface.idOfIp(ip)
				if (node === :error) do
					Interface.execute_client(String.split(orden),gen_reference(),ip, false)
				else
					isNodeUp = ClientInterface.isNodeUp(node)
					Interface.execute_client(String.split(orden),node,ip, isNodeUp)
				end
			end		
		else
			ClientInterface.start()
			execute(orden,ip)
		end
	end

	# Ejecuta ordenes provenientes de nodos base
	def execute_client(["CONNECT"], name, ip, false) do
			ClientInterface.addNode(name, ip)
			ClientInterface.nodeUp(name)
	end

	def execute_client(["DISCONNECT"], name, _, true) do
			ClientInterface.isNodeUp(name)
			ClientInterface.nodeDown(name)
	end

	def execute_client(["WANT", fileId], _, _, true), do:
			ClientInterface.want(fileId)

	def execute_client(["OFFER", fileId, file], name, _, true), do:
			ClientInterface.offer(fileId, file, name)
	
	def execute_client(["CONNECT"], _, _, true), do: "YA ESTÁS CONECTADO"

	def execute_client(_, _, _, false), do: "NO ESTÁS CONECTADO"

	def execute_client(_, _, _, _), do: "FORMAT INCORRECT"

	# Ejecuta ordenes provenientes de administradores
	def execute_admin(["STOP"]), do: ClientInterface.stop()

	def execute_admin(["ADD", "NODEM", nodeMId, nodeMIp]), do: ClientInterface.addNodeM(nodeMId,nodeMIp)

	def execute_admin(["REMOVE", "NODEM", nodeMId]), do: ClientInterface.removeNodeM(nodeMId)

	def execute_admin(["VIEW"]), do: ClientInterface.viewAll()

	def execute_admin(_), do: "FORMAT INCORRECT"

	#Genera un string aleatorio
	def gen_reference() do
 		min = String.to_integer("100000", 36)
 		max = String.to_integer("ZZZZZZ", 36)
  		max
  		|> Kernel.-(min)
  		|> :rand.uniform()
  		|> Kernel.+(min)
  		|> Integer.to_string(36)
	end

end

 # import Interface
 # execute_admin("START")
 # execute_admin("ADD NODE Node1 10.10.10.10")
 # execute_admin("ADD NODE Node2 20.10.10.10")
 # execute_admin("VIEW NODES")
 # execute_admin("ADD NODEM NodeM1 33.33.33.33")
 # execute_admin("VIEW NODESM")
 # execute_admin("NODE UP Node1")
 ## execute_admin("NODEM SYNC NodeM1 []")
 # execute_admin("VIEW NODES")
 # execute_admin("VIEW NODESM")
 # execute_admin("ADD FILE File1 file")
 # execute_admin("ADD NODES_TO_FILE File1 Node1-Node2")
 # execute_admin("VIEW FILES")
 # execute_admin("REMOVE NODES_TO_FILE File1 Node1-Node2")
 # execute_admin("VIEW FILES")
 # execute_admin("REMOVE NODEM NodeM1")
 # execute_admin("REMOVE NODE Node2")
 # execute_admin("REMOVE FILE File1")
 # execute_admin("VIEW")
 # execute_admin("STOP")
