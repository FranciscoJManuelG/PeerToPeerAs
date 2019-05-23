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

# Requisitos funcionales
* Establecer nodo como "disponible" para las peticiones de ficheros 
* Ofrecer un fichero
* Pedir un fichero al sistema y descargarlo
* Desconectarse del sistema

# Explicación de la arquitectura
## Diseño
* El sistema será empleado por dos tipos de usuarios: administrador y cliente. El cliente se relacionará directamente con los nodos base, mientras que el administrador tendrá la capacidad de conectarse a los nodos intermedios, los cuales se comunican con los nodos base mediante un balanceador de carga que impidirá la sobrecarga del sistema. 
* Se dispone de una interfaz de usuario, mediante la cual el cliente podrá realizar las peticiones de "Oferta de documentos" y de "Solicitud de semilla de documento". Una vez recibida la solicitud, el nodo base enviará la información al distribuidor, que se encargará de transmitirlo al nodo intermedio más apropiado, que proporcionará la información necesaria. 
* Los nodos base se conectarán directamente entre si para la compartición de los ficheros, de tal forma que el nodo que enviará un fichero se comunica con el que lo va a recibir, y viceversa.

## Tácticas
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

# Utilización

## Usuario

**Se conecta el Peer**
```elixir
Peer.connect()
```
Se conecta al nodo intermedio con ip y puerto que está en el fichero de configuración. 
De esta manera se añade y/o establece como levantado el nodo en el servidor y se inicia el servidor interno del Peer en el puerto 4000.

**El peer ofrece un fichero**
```elixir
Peer.offer("nombre_del_fichero")
```
El fichero debe estar en la ruta que se establece en el fichero de configuración. Se añade al nodo intermedio y se muestra esta ip como disponible para descargar.

**El peer quiere un fichero**
```elixir
Peer.want("nombre_del_fichero")
```
El nodo intermedio puede devolver un "File not found" en caso de que no exista ese fichero o "ip hash"

**El peer descarga un fichero**
```elixir
Peer.give_me_file("ip_nodo","nombre_del_fichero","hash")
```
Si el fichero se descarga y el hash es el correcto la descarga se realizará correctamente.
Si el fichero que se recibe no tiene el mismo hash que el aportado por el servidor la descarga se abortará.

**El peer se desconecta**
```elixir
Peer.disconnect()
```
El nodo pasa a estar desconectado en el nodo intermedio y se apaga el servidor local.

## Administrador

**Se inicia el Nodo Intermedio.**
```elixir
Server.accept()
```
Se inicia en el puerto 5000.

El administrador puede realizar todas las funciones que puede hacer un usuario normal pero a mayores puede ver el estado del nodo intermedio.

**Ver estructura del Nodo Intermedio**
```elixir
AdminPeer.view()
```

**Añadir Nodo Intermedio**
```elixir
AdminPeer.add_nodeM("id_nodoM","ip_nodoM")
```

**Añadir Nodo Intermedio**
```elixir
AdminPeer.remove_nodeM("id_nodoM")
```

De momento los Nodos Intermedios se añaden como :UNSYNC (desincronizados) a una lista del Nodo Intermedio al que estamos conectados pero no tiene funcionalidad. En un futuro estos Nodos Intermedios se comunicarían entre sí y se sincronizarían cada cierto tiempo.
