defmodule AdminOperations do

  def addNodeM(nodeM, ip) do
    GenServer.cast(:server, {:addNodeM, nodeM, ip})
    "Añadiendo nodo maestro con id '#{nodeM}' e ip '#{ip}'."
  end

  def removeNodeM(nodeM) do
	  GenServer.cast(:server, {:removeNodeM, nodeM})
		"Eliminando nodo maestro '#{nodeM}'"
	end

  def viewAll() do
	  GenServer.call(:server, :viewAll)
  end
    
end