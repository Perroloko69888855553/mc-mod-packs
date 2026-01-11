# Configuración: ajusta estas rutas
$zipUrl = "https://github.com/Perroloko69888855553/mc-mod-packs/archive/refs/heads/main.zip"
$tempDir = "$env:TEMP\mc-mod-pack"
$modsDir = "C:\Users\$env:USERNAME\AppData\Roaming\.minecraft\mods"  # Cambia si usas launcher como CurseForge o versión específica, ej: ...\instances\MiPack\mods

# Crear directorio temporal
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# Descargar ZIP
Write-Host "Descargando ZIP..."
Invoke-WebRequest -Uri $zipUrl -OutFile "$tempDir\main.zip"

# Extraer ZIP (usando Expand-Archive, nativo en PowerShell 5+)
Write-Host "Extrayendo..."
Expand-Archive -Path "$tempDir\main.zip" -DestinationPath $tempDir -Force

# Encontrar y copiar archivos .jar a la carpeta de mods
$extractedPath = Get-ChildItem $tempDir -Recurse -Directory -Name "mc-mod-packs-main" | Select-Object -First 1
if ($extractedPath) {
    $sourceMods = Get-ChildItem "$tempDir\$extractedPath\*.jar" -Recurse
    if ($sourceMods.Count -eq 0) {
        Write-Warning "No se encontraron archivos .jar en el ZIP. Verifica el contenido."
    } else {
        # Crear carpeta mods si no existe
        if (!(Test-Path $modsDir)) { New-Item -ItemType Directory -Path $modsDir -Force | Out-Null }
        
        # Copiar .jar
        foreach ($jar in $sourceMods) {
            Copy-Item $jar.FullName "$modsDir\$($jar.Name)" -Force
            Write-Host "Copiado: $($jar.Name)"
        }
        Write-Host "¡Mods instalados en $modsDir! Hay $($sourceMods.Count) archivos."
    }
} else {
    Write-Error "No se encontró la estructura esperada en el ZIP."
}

# Limpiar temporal
Remove-Item $tempDir -Recurse -Force
Write-Host "Limpieza completada."
