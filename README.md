# Participantes:
+ Borja Álvarez Piñeiro
+ Iván Barrientos Lema 
+ Anxo Cristobo Fabeiro
+ David García Gondell
+ Francisco Javier Manuel García 
+ Nuria Méndez Casás
+ Iván González Dopico

# Descripción de la app
* Necesitamos un sistema de compartición de ficheros que se usará en el ámbito académico para compartir los contenidos impartidos entre varias Universidades. 
* Este sistema ha de tener una alta disponibilidad al que puedan estar subiendo y descargando ficheros entre varios miembros de la red de forma simultánea, dejando a los usuarios de la red la capacidad de manejar los archivos que quieren compartir o dejar de compartir en todo momento. 
* Se debe asegurar la integridad de los datos y debe estar en funcionamiento casi todo el tiempo. 
* En cuanto a escalabilidad debe ser escalable desde unos pocos usuarios hasta varios centenares.

# Explicación de la arquitectura
# Diseño
* El sistema será empleado por dos tipos de usuarios: administrador y cliente. El cliente se relacionará directamente con los nodos base, mientras que el administrador tendrá la capacidad de conectarse a los nodos intermedios, los cuales se comunican con los nodos base mediante un balanceador de carga que impidirá la sobrecarga del sistema. 
* Se dispone de una interfaz de usuario, mediante la cual el cliente podrá realizar las peticiones de "Oferta de documentos" y de "Solicitud de semilla de documento". Una vez recibida la solicitud, el nodo base enviará la información al distribuidor, que se encargará de transmitirlo al nodo intermedio más apropiado, que proporcionará la información necesaria. 
* Los nodos base se conectarán directamente entre si para la compartición de los ficheros, de tal forma que el nodo que enviará un fichero se comunica con el que lo va a recibir, y viceversa.


# Tácticas
* Reducción de la sobrecarga computacional:
Por definición de la propia arquitectura que reparte la sobrecarga entre los distintos nodos.
* Introducción a la concurrencia
En Server.exs se define una función `loop` que crea un thread por cada cliente que se conecta y delega la conexión
en este hilo nuevo.
* Arbitraje de recursos FIFO
La función anterior atiende las peticiones de los clientes con 
```elixir
:gen_tcp.accept(serverSocket)
```
el cual sirve las conexiones de los clientes de esta forma.
* Integridad de datos
Se utiliza una función hash para asegurarnos que los ficheros sean iguales.
* Autorización de usuarios
Hay dos niveles de usuario, donde el uno es el administrador de nodos intermedios y el otro el cliente.
* Identificación de atacantes
Se guarda en el fichero `server_log` toda la información de los errores incluso la de los
atacantes.



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

