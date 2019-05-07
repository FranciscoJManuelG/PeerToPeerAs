defmodule Utils do

	############################## FUNCIONES AUXILIARES ###########################
	# Busca la id de una ip
	def idOfIp(ip,[{id,_,ip}|_]), do: id

	def idOfIp(ip,[_|tail]), do: idOfIp(ip,tail)

	def idOfIp(_,[]), do: :error

	######################################################
	# Busca si un nodo está :UP
	def nodeIsUpFunction(nodeId, [{nodeId,:UP,_}|_]), do: true
	
	def nodeIsUpFunction(nodeId, [{nodeId,:DOWN,_}|_]), do: false

	def nodeIsUpFunction(nodeId, [_|tail]), do: nodeIsUpFunction(nodeId, tail)

	def nodeIsUpFunction(_,_), do: false

	####################################################
	# Busca la ip correspondiente a un nodo
	def ipByNode(nodeId, [{nodeId,_, ip}|_]), do: ip

	def ipByNode(node, [_|tail]), do: ipByNode(node,tail)

	def ipByNode(_), do: "ERROR"

	####################################################
	# Busca una lista de nodos de un fichero
	def nodesByFile(fileId, [{fileId,_,listNodes}|_]), do: listNodes

	def nodesByFile(fileId, [_|tail]), do: nodesByFile(fileId, tail)

	def nodesByFile(_,_), do: []

 	####################################################
 	# Para saber si existe un nodo o un fichero
 	def exists(id_node, [{id_node, _, _}|_]), do: true
 	def exists(id_file, [{id_file, _, _}|_]), do: true

 	def exists(id, [_|tail]), do: exists(id, tail)

 	def exists(_,_), do: false

	####################################################
	# Para eliminar un nodo
	def delete(id_node,list), do: delete(id_node,list,[])

	def delete(_,[],aux), do: aux

	def delete(id_node,[{id_node,_,_}|tail],aux), do:  Enum.concat(aux,tail)

	def delete(id_node,[node|tail],aux), do: delete(id_node, tail, [node | aux])

	############################################################
	# Modificar estado de un nodo
	def nodeStateFunction(nodeId, state, list), do:	
		nodeStateFunction(nodeId, state, list, [])

	def nodeStateFunction(nodeId, state, [{nodeId, _, ip}|tail], aux), do:
		Enum.concat(aux,[{nodeId, state, ip}|tail])

	def nodeStateFunction(node, status, [head|tail], aux), do:
		nodeStateFunction(node, status, tail, [head|aux])

	def nodeStateFunction(_, _, _, aux), do: aux

	#############################################################
	# Añade un nodo a un fichero
	def addNodeToFileFunction(fileId, node, listFilesNodes), do:
		addNodeToFileFunction(fileId, node, listFilesNodes, [])

	def addNodeToFileFunction(fileId, node, [{fileId, hash, file, listNodes}|tail], listAux), do:
		Enum.concat(listAux, [{fileId, hash, file, [node | listNodes]} | tail])

	def addNodeToFileFunction(fileId, node, [node|tail], listAux), do:
		addNodeToFileFunction(fileId, node, tail, [node | listAux])

	def addNodeToFileFunction(_, _, [], listAux), do: listAux

	############################################################
	# Comprueba si el nodo esta en la lista
	def inList?(node, [node|_]), do: true		

	def inList?(node, [_|tail]), do: inList?(node,tail)

	def inList?(_, _), do: false

end