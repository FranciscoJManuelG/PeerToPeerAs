defmodule Utils do

	############################## FUNCIONES AUXILIARES ###########################

	def idOfIp(ip,[{id,_,ip}|_]), do: id

	def idOfIp(ip,[_|tail]), do: idOfIp(ip,tail)

	def idOfIp(_,[]), do: :error

	######################################################
	def nodeIsUpFunction(nodeId, [{nodeId,:UP,_}|_]), do: true
	
	def nodeIsUpFunction(nodeId, [{nodeId,:DOWN,_}|_]), do: false

	def nodeIsUpFunction(nodeId, [_|tail]), do: nodeIsUpFunction(nodeId, tail)

	def nodeIsUpFunction(_,_), do: false

	####################################################

	def ipByNode(nodeId, [{nodeId,_, ip}|_]), do: ip

	def ipByNode(node, [_|tail]), do: ipByNode(node,tail)

	def ipByNode(_), do: "ERROR"

	####################################################

	def nodesByFile(fileId, [{fileId,_,_,listNodes}|_]), do: listNodes

	def nodesByFile(fileId, [_|tail]), do: nodesByFile(fileId, tail)

	def nodesByFile(_, _), do: []

 	####################################################

 	# Para sabes si existe un nodo

 	def exists(id_want, [{id_want, _, _}|_]), do: true

 	def exists(id_want, [{_, _, _}|tail]), do: exists(id_want, tail)

 	# Para sabes si existe un fichero

 	def exists(id_want, [{id_want, _, _, _}|_]), do: true

 	def exists(id_want, [{_, _, _, _}|tail]), do: exists(id_want, tail)

 	def exists(_,_), do: false

	####################################################

	def delete(id_want,list), do: delete(id_want,list,[])

	def delete(_,[],aux), do: aux

	# Para eliminar un nodo

	def delete(id_want,[{id_want,_,_}|tail],aux), do: aux ++ tail

	def delete(id_want,[{id_list,state,ip}|tail],aux), do: delete(id_want, tail, aux++[{id_list,state,ip}])

	############################################################

	def nodeStateFunction(nodeId, state, list) do
		nodeStateFunction(nodeId, state, list, [])
	end

	def nodeStateFunction(nodeId, state, [{nodeId, _, ip}|tail], aux) do
		Enum.concat(aux,[{nodeId, state, ip}|tail])
	end

	def nodeStateFunction(node, status, [head|tail], aux) do
		nodeStateFunction(node, status, tail, [head|aux])
	end

	def nodeStateFunction(_, _, _, aux) do
		aux
	end

################################################################
	def addNodeToFileFunction(fileId, node, listFilesNodes) do
		addNodeToFileFunction(fileId, node, listFilesNodes, [])
	end

	def addNodeToFileFunction(fileId, node, [{fileId, hash, file, listNodes}|tail], listAux) do
		listAux ++ [{fileId, hash, file, listNodes++[node]}|tail]
	end

	def addNodeToFileFunction(fileId, node, [{other_fileId, hash, file, listNodes}|tail], listAux) do
		addNodeToFileFunction(fileId, node, tail, listAux ++ [{other_fileId, hash, file, listNodes}])
	end

	def addNodeToFileFunction(_, _, [], listAux) do
		listAux
	end

###############################################################

	def inList?(node, [head|_])
		when node == head do true		
	end

	def inList?(node, [head|tail])
		when node != head do inList?(node,tail)
	end

	def inList?(_, _), do: false

end
