# Builds the site: src/app.html -> index.html (adds PWA head and service worker registration).
# Usage:  powershell -NoProfile -File build.ps1          (icons are redrawn only with -Icons)
param([switch]$Icons)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding $false

$app = [IO.File]::ReadAllText((Join-Path $root 'src\app.html'), $utf8)
$head = @'
<!doctype html>
<html lang="ru">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-title" content="&#1055;&#1091;&#1083;&#1100;&#1090;">
<meta name="apple-mobile-web-app-status-bar-style" content="default">
<meta name="theme-color" content="#F1F2F5" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#0E1015" media="(prefers-color-scheme: dark)">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<link rel="icon" href="icon-192.png">
<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}</style>
</head>
<body>
'@
$tail = @'
<script>
if ('serviceWorker' in navigator && location.protocol === 'https:') navigator.serviceWorker.register('./sw.js');
</script>
</body>
</html>
'@
[IO.File]::WriteAllText((Join-Path $root 'index.html'), $head + "`n" + $app + "`n" + $tail + "`n", $utf8)

if ($Icons) {
  Add-Type -AssemblyName System.Drawing
  function New-Icon([int]$size, [string]$path) {
    $bmp = New-Object Drawing.Bitmap $size, $size
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([Drawing.ColorTranslator]::FromHtml('#1B2240'))
    $pad = [int]($size * 0.22); $gap = [int]($size * 0.05)
    $cell = [int](($size - 2 * $pad - $gap) / 2)
    $cols = '#D2263A', '#E0701C', '#D8A30F', '#8B929E'
    for ($k = 0; $k -lt 4; $k++) {
      $x = $pad + ($k % 2) * ($cell + $gap); $y = $pad + [math]::Floor($k / 2) * ($cell + $gap)
      $r = [int]($cell * 0.22); $d = 2 * $r
      $p = New-Object Drawing.Drawing2D.GraphicsPath
      $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $cell - $d, $y, $d, $d, 270, 90)
      $p.AddArc($x + $cell - $d, $y + $cell - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $cell - $d, $d, $d, 90, 90)
      $p.CloseFigure()
      $g.FillPath((New-Object Drawing.SolidBrush ([Drawing.ColorTranslator]::FromHtml($cols[$k]))), $p)
    }
    $bmp.Save($path, [Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
  }
  New-Icon 180 (Join-Path $root 'apple-touch-icon.png')
  New-Icon 192 (Join-Path $root 'icon-192.png')
  New-Icon 512 (Join-Path $root 'icon-512.png')
}
Write-Output 'Built index.html'
