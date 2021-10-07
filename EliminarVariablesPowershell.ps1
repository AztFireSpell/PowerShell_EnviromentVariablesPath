if (Test-Path -Path Env:/JAVA_HOME){
	REG delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V "JAVA_HOME"
}

$patharray = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path

$patharray = $patharray.Split(';')

for($num1 = 0; $num1 -lt $patharray.length; $num1++){
    #en LastIndexOf cambiaras el valor, este sera buscado y eliminado del path
if(($patharray[$num1].ToLower().LastIndexOf('java\jre') -ne -1 ) -or $patharray[$num1].ToLower().LastIndexOf('java_home') -ne -1  ){    
    $patharray[$num1] = 'remove'
    }
}

$Remove = 'remove'
$patharray = ($patharray.Split(';') | Where-Object -FilterScript {$_ -ne $Remove}) -join ';'

$patharray

SETX /M PATH $patharray

