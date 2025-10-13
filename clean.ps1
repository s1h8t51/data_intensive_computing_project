Write-Output "Clearing Datanode 1"
Remove-Item -Path ".\hadoop\datanode1\" -Recurse -Force
New-Item -Path ".\hadoop\datanode1\" -ItemType Directory
Write-Output "Clearing Datanode 2"
Remove-Item -Path ".\hadoop\datanode2\" -Recurse -Force
New-Item -Path ".\hadoop\datanode2\" -ItemType Directory
Write-Output "Clearing Name Node"
Remove-Item -Path ".\hadoop\namenode\" -Recurse -Force
New-Item -Path ".\hadoop\namenode\" -ItemType Directory
