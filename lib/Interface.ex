defmodule Interface do

	def execute(orden, ip) do
		if Process.whereis(:server) != nil do
			#Si es una ip admin ejecuta execute_admin, si no, ejecuta execute_client
			if ClientInterface.isAdmin(ip) do
				Interface.execute_admin(orden)
			else 
				node = ClientInterface.idOfIp(ip)
				if (node === :error) do
					Interface.execute_client(orden,gen_reference(),ip)
				else
					Interface.execute_client(orden,node,ip)
				end
			end		
		else
			ClientInterface.start()
			execute(orden,ip)
		end
	end

	# Ejecuta ordenes provenientes de nodos base
	def execute_client(orden, name, ip) do
		case String.split(orden) do
			["CONNECT"] -> 			if not ClientInterface.isNodeUp(name) do
										ClientInterface.addNode(name, ip)
										ClientInterface.nodeUp(name)
									else "YA ESTÁS CONECTADO"
									end
			["DISCONNECT"] -> 		if ClientInterface.isNodeUp(name) do
										ClientInterface.nodeDown(name)
									else "NO ESTÁS CONECTADO"
									end
			["WANT", fileId] -> 	if ClientInterface.isNodeUp(name) do
										ClientInterface.want(fileId)
									else "NO ESTÁS CONECTADO"
									end
			["OFFER", fileId, file] -> 	if ClientInterface.isNodeUp(name) do
										ClientInterface.offer(fileId, file, name)
									else "NO ESTÁS CONECTADO"
									end
			_-> "FORMAT INCORRECT"
		end
	end

	# Ejecuta ordenes provenientes de administradores
	def execute_admin(orden) do
		case String.split(orden) do
			["STOP"] -> ClientInterface.stop()
			["ADD", "NODEM", nodeMId, nodeMIp] -> ClientInterface.addNodeM(nodeMId,nodeMIp)
			["REMOVE", "NODEM", nodeMId] -> ClientInterface.removeNodeM(nodeMId)
			["VIEW"] -> ClientInterface.viewAll()
			_-> "FORMAT INCORRECT"
		end
	end

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
