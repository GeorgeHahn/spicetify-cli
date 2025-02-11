$curVer = Invoke-WebRequest -UseBasicParsing "https://api.github.com/repos/khanhas/spicetify-cli/releases/latest" | ConvertFrom-Json
Write-Host "Current version:", $curVer.tag_name

function Dist {
    param (
        [Parameter(Mandatory = $true)][int16]$major,
        [Parameter(Mandatory = $true)][int16]$minor,
        [Parameter(Mandatory = $true)][int16]$patch
    )

    $version = "$($major).$($minor).$($patch)"
    $nameVersion = "spicetify-$version"
    

    function build($dest) {
        go build  -ldflags "-X main.version=$version" -o $dest
    }

    if (Test-Path "./bin") {
        Remove-Item -Recurse "./bin"
    }

    # 64-bit
    $env:GOARCH = "amd64"

    Write-Host "Building Linux binary:"
    $env:GOOS = "linux"

    build "./bin/linux/spicetify"

    7z a -bb0 "./bin/linux/$($nameVersion)-linux-amd64.tar" "./bin/linux/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-linux-amd64.tar.gz" "./bin/linux/$($nameVersion)-linux-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building MacOS binary:"
    $env:GOOS = "darwin"

    build "./bin/darwin/spicetify"

    7z a -bb0 "./bin/darwin/$($nameVersion)-darwin-amd64.tar" "./bin/darwin/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-darwin-amd64.tar.gz" "./bin/darwin/$($nameVersion)-darwin-amd64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    Write-Host "Building Windows binary:"
    $env:GOOS = "windows"

    build "./bin/windows/spicetify.exe"

    7z a -bb0 -mx9 "./bin/$($nameVersion)-windows-x64.zip" "./bin/windows/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    # 32-bit
    $env:GOARCH = "386"

    Write-Host "Building Windows 32-bit binary:"
    $env:GOOS = "windows"

    build "./bin/windows32/spicetify.exe"

    7z a -bb0 -mx9 "./bin/$($nameVersion)-windows-x32.zip" "./bin/windows32/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green

    # ARM
    $env:GOARCH = "arm64"

    Write-Host "Building MacOS ARM binary:"
    $env:GOOS = "darwin"

    build "./bin/darwin-arm/spicetify"

    7z a -bb0 "./bin/darwin-arm/$($nameVersion)-darwin-arm64.tar" "./bin/darwin-arm/*" "./CustomApps" "./Extensions" "./Themes" "./jsHelper" "globals.d.ts" "css-map.json" >$null 2>&1
    7z a -bb0 -sdel -mx9 "./bin/$($nameVersion)-darwin-arm64.tar.gz" "./bin/darwin-arm/$($nameVersion)-darwin-arm64.tar" >$null 2>&1
    Write-Host "✔" -ForegroundColor Green
}

function Format {
    prettier --write .\Extensions\*.js ".\jsHelper\{homeConfig,sidebarConfig,expFeatures}.js" "CustomApps\*\*{.js,.css}"
}

Format
Dist
