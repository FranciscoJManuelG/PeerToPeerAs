defmodule ClientOperations do

  	def addNode(node, ip) do
  		GenServer.cast(:server, {:addNode, node, ip})
  		"Añadiendo nodo base con id '#{node}' e ip '#{ip}'."
  	end  	

	def nodeUp(node) do
  		GenServer.cast(:server, {:nodeUp, node})
  		"Estableciendo nodo base como activo '#{node}'"
  	end

  	def nodeDown(node) do
  		GenServer.cast(:server, {:nodeDown, node})
  		"Estableciendo nodo base como apagado '#{node}'"
  	end

	def offer(fileId, hash, node) do
		GenServer.cast(:server, {:addFile, fileId, hash, node})
		"Ahora el nodo '#{node}' tiene disponible el fichero '#{fileId}' "
	end

	def want(fileId) do
		GenServer.call(:server, {:viewFile, fileId})
	end

	def idOfIp(ip) do
		GenServer.call(:server, {:idOfIp, ip},:infinity)
	end

end