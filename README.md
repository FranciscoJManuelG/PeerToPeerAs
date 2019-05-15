# Participantes:
+ Borja Álvarez Piñeiro
+ Iván Barrientos Lema 
+ Anxo Cristobo Fabeiro
+ David García Gondell
+ Francisco Javier Manuel García 
+ Nuria Méndez Casás
+ Iván González Dopico

# Descripción de la app

# Explicación de la arquitectura

# Tácticas
* Reducción de la sobrecarga computacional:
Por definición de la propia arquitectura que reparte la sobrecarga entre los distintos nodos
* Introducción a la concurrencia
En Server.exs se define una función `loop` que crea un thread por cada cliente que se conecta y delega la conexión
en este hilo nuevo.
* Arbitraje de recursos FIFO
La función anterior atiende las peticiones de los clientes con 
``` elixir
:gen_tcp.accept(serverSocket)
```
el cual sirve las conexiones de los clientes de esta forma
* Integridad de datos
Se utiliza una función hash para asegurarnos que los ficheros sean iguales
* Autorización de usuarios
Hay dos niveles de usuario, donde el uno es el administrador de nodos intermedios y el otro el cliente
* Identificación de atacantes
Se guarda en el fichero `server_log` toda la información de los errores incluso la de los
atacantes



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `server` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:server, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm).

