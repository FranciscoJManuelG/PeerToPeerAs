defmodule Interface do

	alias ClientOperations, as: Client
	alias AdminOperations, as: Admin
	alias InterfaceOperations, as: Iface

	def execute(orden, ip), do: execute(orden,ip,Process.whereis(:server) != nil)
	def execute(orden, ip, false) do
		Iface.start()
		execute(orden,ip,true)
	end
	def execute(orden,ip,true) do 
		#Si es una ip admin ejecuta execute_admin, si no, ejecuta execute_client
		if Iface.isAdmin(ip) do
			execute_admin(String.split(orden))
		else
			execute(String.split(orden),ip,Client.idOfIp(ip))
		end
	end
	def execute(orden,ip,:error),do: execute_client(orden,gen_reference(),ip, false)
	def execute(orden,ip,node),do: execute_client(orden,node,ip,Iface.isNodeUp(node))

	# Ejecuta ordenes provenientes de administradores
	def execute_admin(["ADD", "NODEM", nodeMId, nodeMIp]), do: Admin.addNodeM(nodeMId,nodeMIp)
	def execute_admin(["REMOVE", "NODEM", nodeMId]), do: Admin.removeNodeM(nodeMId)
	def execute_admin(["VIEW"]), do: Admin.viewAll()
	def execute_admin(orden) do
		ip = Utils.get_own_ip()
		execute(orden,ip,Client.idOfIp(ip))
	end

	# Ejecuta ordenes provenientes de nodos base
	def execute_client(["CONNECT"], name, ip, false) do
		Client.addNode(name, ip)
		Client.nodeUp(name)
	end
	def execute_client(["DISCONNECT"], name, _, true), do: Client.nodeDown(name)
	def execute_client(["WANT", fileId], _, _, true), do: Client.want(fileId)
	def execute_client(["OFFER", fileId, file], name, _, true), do: Client.offer(fileId, file, name)
	def execute_client(["CONNECT"], _, _, true), do: "YA ESTÁS CONECTADO"
	def execute_client(_, _, _, false), do: "NO ESTÁS CONECTADO"
	def execute_client(_, _, _, _), do: "FORMAT INCORRECT"

	#Genera un string aleatorio
	def gen_reference() do
		Ecto.UUID.generate
	end

end