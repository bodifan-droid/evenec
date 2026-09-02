$inkscape = "C:\Program Files\Inkscape\bin\inkscape.com"

if (!(Test-Path $inkscape)) {
    $inkscape = "C:\Program Files\Inkscape\bin\inkscape.exe"
}

Get-ChildItem -Recurse -Filter *.svg |
Where-Object { $_.FullName -like "*assets\diagrams*" } |
ForEach-Object {

    $png = [System.IO.Path]::ChangeExtension($_.FullName, ".png")

    Write-Host "Converting $($_.Name)"

    & $inkscape `
        $_.FullName `
        --export-type=png `
        --export-dpi=300 `
        --export-filename=$png
}