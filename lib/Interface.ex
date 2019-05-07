defmodule Interface do
	alias ClientOperations, as: Client

	def execute(orden, ip), do: execute(orden,ip,Process.whereis(:server) != nil)
	def execute(orden, ip, false) do
		Client.start()
		execute(orden,ip,true)
	end
	def execute(orden,ip,true) do 
		#Si es una ip admin ejecuta execute_admin, si no, ejecuta execute_client
		if Client.isAdmin(ip) do
			Interface.execute_admin(String.split(orden))
		else 
			node = Client.idOfIp(ip)
			if (node === :error) do
				Interface.execute_client(String.split(orden),gen_reference(),ip, false)
			else
				isNodeUp = Client.isNodeUp(node)
				Interface.execute_client(String.split(orden),node,ip, isNodeUp)
			end
		end	
	end

	# Ejecuta ordenes provenientes de nodos base
	def execute_client(["CONNECT"], name, ip, false), do: Client.addNode(name, ip)

	def execute_client(["DISCONNECT"], name, _, true), do: Client.nodeDown(name)

	def execute_client(["WANT", fileId], _, _, true), do: Client.want(fileId)

	def execute_client(["OFFER", fileId, file], name, _, true), do: Client.offer(fileId, file, name)
	
	def execute_client(["CONNECT"], _, _, true), do: "YA ESTÁS CONECTADO"

	def execute_client(_, _, _, false), do: "NO ESTÁS CONECTADO"

	def execute_client(_, _, _, _), do: "FORMAT INCORRECT"

	# Ejecuta ordenes provenientes de administradores
	def execute_admin(["STOP"]), do: Client.stop()

	def execute_admin(["ADD", "NODEM", nodeMId, nodeMIp]), do: Client.addNodeM(nodeMId,nodeMIp)

	def execute_admin(["REMOVE", "NODEM", nodeMId]), do: Client.removeNodeM(nodeMId)

	def execute_admin(["VIEW"]), do: Client.viewAll()

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
