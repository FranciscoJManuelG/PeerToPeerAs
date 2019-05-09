defmodule Client do
    alias ClientConection, as: Conection

    def connect(), do: connect('127.0.0.1',5000)
    def connect(ip,port), do: Conection.connect(ip,port)

    def send(message) do
    	if is_binary(message) do 
    		Conection.send(message)
    	else
    		IO.puts("El mensaje debe ser un String")
    	end
    end

    def want(ip,port,file),do: Conection.want_file(ip,port,file)
    
    def close(), do: Conection.close()
end