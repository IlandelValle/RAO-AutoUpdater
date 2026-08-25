# RAO AutoUpdater

Repositorio de distribución del cliente de Rhember Argentum Online. Conserva
manifests, scripts de publicación y paquetes históricos utilizados por
RAO-Launcher.

## Estado actual

Este repositorio está privado e inactivo. No se utiliza como canal de
actualizaciones por el momento.

Al ser privado:

- raw.githubusercontent.com no entrega manifest.json a jugadores anónimos;
- los assets de Releases requieren autenticación;
- el launcher no puede actualizar una instalación normal;
- un cliente ya instalado puede seguir iniciándose desde el launcher.

No se debe incorporar un token personal al launcher para evitar esta
restricción. Cuando se reactive la distribución, la opción recomendada es
publicar manifest y ZIP en un endpoint HTTPS diseñado para descargas.

## Contenido

- manifest.schema.json: contrato del manifest.
- manifest.example.json: ejemplo sin datos operativos.
- manifest.json: última publicación histórica.
- Version.txt: referencia de versión utilizada por el flujo anterior.
- scripts/Publish-RAOClientRelease.ps1: validador y publicador.
- Parche*.zip: paquetes históricos versionados en el repositorio.

## Formato del manifest

~~~json
{
  "version": "0.1.0-test.1",
  "download_url": "https://updates.example.com/RAO-Client-0.1.0-test.1-windows-x86_64.zip",
  "sha256": "64 caracteres hexadecimales en minúscula",
  "executable": "rao-client.exe"
}
~~~

El ZIP debe contener rao-client.exe en su raíz. El launcher compara el SHA-256
antes de extraer e instalar.

## Requisitos para administrar publicaciones

- PowerShell.
- Git.
- GitHub CLI autenticado con permisos sobre el repositorio.
- Un ZIP de Windows generado desde el cliente actual.

## Previsualizar una publicación

La previsualización valida el archivo y genera el manifest sin modificar
GitHub:

~~~powershell
.\scripts\Publish-RAOClientRelease.ps1 -ArchivePath C:\ruta\RAO-Client-0.1.0-test.1-windows-x86_64.zip -Version 0.1.0-test.1
~~~

## Publicar

No ejecutar este paso mientras el updater permanezca retirado. Cuando se
decida reactivarlo:

~~~powershell
.\scripts\Publish-RAOClientRelease.ps1 -ArchivePath C:\ruta\RAO-Client-0.1.0-test.1-windows-x86_64.zip -Version 0.1.0-test.1 -Publish
~~~

El script:

1. verifica que rao-client.exe esté en la raíz del ZIP;
2. calcula SHA-256;
3. crea un GitHub Release;
4. sube el ZIP;
5. actualiza manifest.json;
6. crea un commit y lo publica en main.

En un repositorio privado, esa publicación sigue siendo privada y no resulta
consumible por un launcher anónimo.

## Probar el contrato sin publicar

~~~powershell
Get-Content manifest.example.json | ConvertFrom-Json | Out-Null
Get-Content manifest.schema.json | ConvertFrom-Json | Out-Null
~~~

La validación completa del publicador puede hacerse con un ZIP temporal que
contenga rao-client.exe y sin utilizar -Publish.

## Relación con el proyecto

El juego está en pre-alpha y actualmente prioriza PvP: targeting, combate,
hechizos, duelos, inventario, comercio, parties, guilds, facciones y
BattleServer. PvE cuenta con NPC, loot, mascotas, interacción y pathfinding,
pero es el área menos madura en contenido, balance y progresión.

## Repositorios relacionados

- AutoUpdater: https://github.com/IlandelValle/RAO-AutoUpdater
- Launcher: https://github.com/IlandelValle/RAO-Launcher
- Cliente: https://github.com/IlandelValle/RAO-Godot-Client
- Servidor: https://github.com/IlandelValle/RAO-Go-Server

## Seguridad

- No almacenar tokens, credenciales o claves en manifests o scripts.
- No publicar IPs reales de servidores.
- Verificar siempre el SHA-256 antes de instalar.
- No reutilizar un ZIP si las fuentes cambiaron después de exportarlo.
