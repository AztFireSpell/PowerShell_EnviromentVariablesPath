powershell.exe -noprofile -NoExit -command "&{start-process powershell -ArgumentList '-NoExit -noprofile -file %~dp0EliminarVariablesPowershell.ps1' -verb RunAs}"