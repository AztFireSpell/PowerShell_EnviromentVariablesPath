# Enviroment Variables Path

# Product Name
> Short blurb about what your product does.

 >¿Te has preguntado como poder eliminar variables de entorno desde poweshell?
 Me enfrente a un caso particular donde teniamos que eliminar java del path, ¿pero como realizarlo de manera automatica?

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)


## Desarrollo del problema

Cuando nos preguntan sobre las variables de entorno, vamos directamente a nuestro windows (menu inicio), escribimos variables de entorno, buscamos y eliminamos, asi de sencillo, ¿Pero, y si esta prohibida la interaccion humana para esta tarea y tiene que ser todo por medio de un script?

De manera general, debemos de considerar que se tienen 2 rutas del path, las de sistema y las de usuario 👀


## Manipular las rutas

Lo primero en todo script es tratar con la informacion, entonces en este caso debemos hacer una "consulta" hacia la ruta donde se encuentran las variables de entorno, para ello dependiendo que uses ya sea powershell o cmd se obtienen de la siguiente forma:

```sh 
Powershell > "Get-ItemProperty" "ruta de variables"
```

```sh 
CMD > REG QUERY "ruta de variables"
```

Dependiendo de cual es la que quieres manipular para elimiar, en windows encontramos 2 rutas principales para tus variables

Acceder a variables de usuario

```sh
"HKCU\Environment"
```

Acceder a variables de sistema

```sh
"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
```

## Obtener todas las variables del path

Una vez comprendido esto, debemos hacer una consulta y guardar el valor en una variable para poder manipular, en este caso convertirlo en un arreglo para una mejor manipulacion


```sh
$patharray = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
```

Con esta consulta entramos al path de sistema, pero la consulta como tal nos devuelve todos los valores, para ello agregamos el parametro -Name "nombre" (en este caso path que es el que nos interesa), pero nos devuelven todos aquellos que tienen path, entonces ahora usamos un . + path para traer solo el valor de path como tal

** Debe ser importante decir que de forma explicita todas las variables estan separadas por un ; por ello lo siguiente es separar la consulta con este valor clave, usamos .split que lo unico que hace es aplicar un salto de linea o espaciado despues de ;

```sh
$patharray = $patharray.Split(';')
```

## Comienza la magia del borrado

Como anteriormente comente existe un ; que no esta tan explicito en estas consulas, mas por el valor del split, ya teniendo todas las variables, ay que encontrar aquellas para eliminar, como comente antes el problema surge con java/jre, en cualquier version de java encontraras esa cadena, entonces eso vamos a atacar

con un for vamos recorriendo la consulta almacenada en $patharray, la sentencia clave a usar es es 

```sh
LastIndexOf('variable a eliminar')
```

Con esto podemos encontrar en la posicion del arreglo la variable a sustutuir, no eliminar de primera instancia, ya que si igualamos a '' o null, mas adelante vamos a presentar con un problema o error, tambien debemos pasar todo el valor a minuscula, asi no importara si esta escrito: Asi, ASi o ASI todo sera asi

1. for($num1 = 0; $num1 -lt $patharray.length; $num1++){    
2. if(($patharray[$num1].ToLower().LastIndexOf('java\jre') -ne -1 ) -or $patharray[$num1]3. .ToLower().LastIndexOf('java_home') -ne -1  ){    
4.     $patharray[$num1] = 'remove'
5.     }
6. }

Presta atencion a la linea 4, cambiamos el valor por un remove, asi que ya estaria eliminado pero ahora como podemos eliminar este nuevo valor del arreglo?

## Eliminando las posiciones y creando el string
Solo debemos crear una variable, llamada $remove, puede ser el nombre que gustes y agregamos la cadena 'remove'
```sh
$Remove = 'remove'
```

la verdadera eliminacion surge a continuacion, si nosotros pasamos directamente el valor de nuestro $patharray, al ser un arreglo nos dara un error, ya que el comando para volver a setear o set las variables solo acepta cadenas de texto.

Debemos convertir el arreglo a string y para ello podemos usar la funcion de join, que lo unico que hace es unir los valores, pero antes debemos volver a hacer un split con el ; invisible para nosotros, pero ahora con la sentencia 

```sh
Where-Object -FilterScript {$_ -ne $Remove}
```

Esto hara omision de la posicion donde se encuentre un remove; que es el valor que seteamos anterioremente, aplicando por completo de esta forma:

```sh
$patharray = ($patharray.Split(';') | Where-Object -FilterScript {$_ -ne $Remove}) -join ';'
```

Listo ya a quedado correctamente eliminado nuestros valores no deseados en las variables de entorno, pero ahora, falta setearlos permanentemente, ya que cada consola de windows maneja de forma temporal las variables

con el siguiente comando:

```sh
SETX /M PATH $patharray
```
Pasamos el valor del string para que quede seteado a la computadora, es importante decir que este comando necesita permisos de administrador para poder ejecutarse, de lo contrario habra un error fatal :)

## Pasos finales

Si has sido curioso con el codigo encontraras que tenemos la siguiente linea
```sh
if (Test-Path -Path Env:/JAVA_HOME){
	REG delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V "JAVA_HOME"
}
```

Anteriormente hemos eliminado las variables dentro del path, sin embargo tambien podemos borrar las variables de forma rapida fuera del path con la sentencia anterior, estos valores suelen ser estaticos, en el caso de java , crea la JAVA_HOME siempre, no importa la version, asi que para eliminarla basta con atacar este valor de forma directa, si quieres eliminar del usuario del sistema basta con modificar el REG delete "esta cadena"

## Pasos finales

Si guardas esto como un ps1, el equivalente a un bat de cmd, te daras cuenta que no se puede ejecutar como adminsitrador, entonces para eso creamos el ejecutarbat, ya que solo invoca el archivo del powershell para ejecutarlo, antes pregunta por permisos de administrador y listo, ahora si puedes ejecutar el programa sin ningun problema :D

## Contact

Soy Alonso Díaz – [@YourTwitter](https://twitter.com/aldark42) –  Saludos 🖖

## Video de Youtube

![YouTube](https://img.shields.io/badge/<alongamecrafter>-%23FF0000.svg?style=for-the-badge&logo=YouTube&logoColor=white)

Proximamente!