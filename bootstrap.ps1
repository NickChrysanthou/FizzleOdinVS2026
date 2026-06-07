$slnx = '<?xml version="1.0" encoding="utf-8"?>
<Solution>
  <Folder Name="/">
    <File Path="src\source.odin" />
    <File Path="ols.json" />
    <File Path="odinfmt.json" />
    <File Path="tasks.vs.json" />
    <File Path="launch.vs.json" />
    <File Path="bootstrap.ps1" />
  </Folder>
</Solution>'

$ols = '{
  "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/ols.schema.json",
  "collections": [
    { "name": "core",   "path": "C:/odin/core" },
    { "name": "vendor", "path": "C:/odin/vendor" }
  ],
  "enable_document_symbols": true,
  "enable_hover": true,
  "enable_snippets": true,
  "enable_inlay_hints": true,
  "enable_inlay_hints_params": true,
  "profile": "default",
  "profiles": [
    { "name": "default", "checker_path": ["src"] }
  ]
}'

$odinfmt = '{
  "$schema": "https://raw.githubusercontent.com/DanielGavin/ols/master/misc/odinfmt.schema.json",
  "character_width": 100,
  "tabs": true,
  "tabs_width": 4,
  "newline_style": "CRLF"
}'

$tasks = '{
  "version": "0.2.1",
  "tasks": [
    {
      "taskName": "Odin Build",
      "appliesTo": "/",
      "type": "launch",
      "command": "C:\\odin\\odin.exe",
      "args": ["build", "src", "-out:bin\\FizzleFramework.exe", "-debug"]
    },
    {
      "taskName": "Odin Run",
      "appliesTo": "/",
      "type": "launch",
      "command": "C:\\odin\\odin.exe",
      "args": ["run", "src", "-debug"]
    },
    {
      "taskName": "Odin Check",
      "appliesTo": "/",
      "type": "launch",
      "command": "C:\\odin\\odin.exe",
      "args": ["check", "src"]
    }
  ]
}'

$launch = '{
  "version": "0.2.1",
  "defaults": {},
  "configurations": [
    {
      "type": "default",
      "name": "FizzleFramework",
      "project": "tasks.vs.json",
      "taskName": "Odin Run"
    }
  ]
}'

$source = 'package main

import "core:fmt"

main :: proc() {
    fmt.println("FizzleFramework starting...")
}'

$enc = [System.Text.UTF8Encoding]::new($false)
$root = $PSScriptRoot

[System.IO.File]::WriteAllText("$root\FizzleFramework.slnx", $slnx, $enc)
[System.IO.File]::WriteAllText("$root\ols.json",             $ols,   $enc)
[System.IO.File]::WriteAllText("$root\odinfmt.json",         $odinfmt, $enc)
[System.IO.File]::WriteAllText("$root\tasks.vs.json",        $tasks, $enc)
[System.IO.File]::WriteAllText("$root\launch.vs.json",       $launch, $enc)

@("src","bin") | ForEach-Object {
    if (!(Test-Path "$root\$_")) { New-Item -ItemType Directory -Path "$root\$_" | Out-Null }
}
if (!(Test-Path "$root\bin\.gitkeep")) { New-Item -Force "$root\bin\.gitkeep" | Out-Null }
if (!(Test-Path "$root\src\source.odin")) {
    [System.IO.File]::WriteAllText("$root\src\source.odin", $source, $enc)
}

Write-Host "Verifying build..." -ForegroundColor Cyan
& "C:\odin\odin.exe" build src -out:bin\FizzleFramework.exe
if ($LASTEXITCODE -eq 0) {
    Write-Host "Build OK. Opening solution..." -ForegroundColor Green
    start "$root\FizzleFramework.slnx"
} else {
    Write-Host "Build failed." -ForegroundColor Red
}