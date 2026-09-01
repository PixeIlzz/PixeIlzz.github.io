Add-Type -AssemblyName System.Drawing

$sp  = "C:\Users\Javier\AppData\Local\Temp\claude\C--Users-Javier-Documents-Portfolio-Web\db1cc24d-fc1b-434a-b893-3bccd5c7580d\scratchpad\matrixH.txt"
$dir = "C:\Users\Javier\Documents\Portfolio-Web\Pixellz.github.io"
$rows = @(Get-Content $sp)
$n = $rows.Count
$s = 30
# Grosor del borde y zona muda, en modulos. El borde va a ras del canto de
# la imagen; la zona muda es el ambar que queda entre el borde y el codigo.
$bordeMods = 0.6
$mudaMods = 2.0
$m = $bordeMods + $mudaMods
$tot = [int]((($n + $m + $m)) * $s)

function New-RR($x, $y, $w, $h, $r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  if ($r -le 0) {
    $p.AddRectangle((New-Object System.Drawing.RectangleF($x, $y, $w, $h)))
    return $p
  }
  $d = $r + $r
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
  $p.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
  $p.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

$bmp = New-Object System.Drawing.Bitmap($tot, $tot)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$navy  = [System.Drawing.Color]::FromArgb(23, 37, 60)
$amber = [System.Drawing.Color]::FromArgb(255, 193, 7)
$g.Clear($amber)
$fg = New-Object System.Drawing.SolidBrush($navy)
$bg = New-Object System.Drawing.SolidBrush($amber)

$finders = @(@(0,0), @(0,26), @(26,0))
$align = @(24,24)
$special = New-Object 'bool[,]' $n, $n
foreach ($f in $finders) {
  for ($i = 0; $i -lt 7; $i++) {
    for ($j = 0; $j -lt 7; $j++) { $special[($f[0] + $i), ($f[1] + $j)] = $true }
  }
}
for ($i = 0; $i -lt 5; $i++) {
  for ($j = 0; $j -lt 5; $j++) { $special[($align[0] + $i), ($align[1] + $j)] = $true }
}

$r7 = 7 * $s
$r5 = 5 * $s
$r3 = 3 * $s
foreach ($f in $finders) {
  $x = ($f[1] + $m) * $s
  $y = ($f[0] + $m) * $s
  $p1 = New-RR $x $y $r7 $r7 (0.85 * $s)
  $g.FillPath($fg, $p1); $p1.Dispose()
  $p2 = New-RR ($x + $s) ($y + $s) $r5 $r5 (0.6 * $s)
  $g.FillPath($bg, $p2); $p2.Dispose()
  $p3 = New-RR ($x + $s + $s) ($y + $s + $s) $r3 $r3 (0.5 * $s)
  $g.FillPath($fg, $p3); $p3.Dispose()
}

$ax = ($align[1] + $m) * $s
$ay = ($align[0] + $m) * $s
$a1 = New-RR $ax $ay $r5 $r5 (0.6 * $s)
$g.FillPath($fg, $a1); $a1.Dispose()
$a2 = New-RR ($ax + $s) ($ay + $s) $r3 $r3 (0.45 * $s)
$g.FillPath($bg, $a2); $a2.Dispose()
$a3 = New-RR ($ax + $s + $s) ($ay + $s + $s) $s $s (0.25 * $s)
$g.FillPath($fg, $a3); $a3.Dispose()

$rmod = 0.22 * $s
for ($i = 0; $i -lt $n; $i++) {
  $row = $rows[$i]
  for ($j = 0; $j -lt $n; $j++) {
    if ($special[$i, $j]) { continue }
    if ($row[$j] -eq '1') {
      $p = New-RR (($j + $m) * $s) (($i + $m) * $s) $s $s $rmod
      $g.FillPath($fg, $p); $p.Dispose()
    }
  }
}

$logoMods = 7.0
$gapMods = 0.6
$cx = $tot / 2.0
$plate = ($logoMods + $gapMods + $gapMods) * $s
$lw = $logoMods * $s
$pp = New-RR ($cx - $plate / 2) ($cx - $plate / 2) $plate $plate (1.7 * $s)
$g.FillPath($bg, $pp); $pp.Dispose()
$logo = New-Object System.Drawing.Bitmap("$dir\Logo.png")
$lp = New-RR ($cx - $lw / 2) ($cx - $lw / 2) $lw $lw (1.5 * $s)
$g.SetClip($lp)
$g.DrawImage($logo, ($cx - $lw / 2), ($cx - $lw / 2), $lw, $lw)
$g.ResetClip()
$lp.Dispose(); $logo.Dispose()

$penW = $bordeMods * $s
$inset = $penW / 2
$pen = New-Object System.Drawing.Pen($navy, $penW)
$pen.Alignment = [System.Drawing.Drawing2D.PenAlignment]::Center
$side = $tot - $inset - $inset
$bp = New-RR $inset $inset $side $side (1.6 * $s)
$g.DrawPath($pen, $bp)
$bp.Dispose(); $pen.Dispose()

$g.Dispose(); $fg.Dispose(); $bg.Dispose()
$bmp.Save("$dir\qr.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$bordeExt = $inset + $penW / 2
$mudaPx = ($m * $s) - $bordeExt
$mudaMod = [math]::Round(($mudaPx / $s), 2)
$bytes = (Get-Item "$dir\qr.png").Length
$ocupa = [math]::Round((100 * $n / ($n + $m + $m)), 1)
Write-Output "imagen cuadrada de $tot px, $bytes bytes"
Write-Output "borde de $penW px, a $bordeExt px del canto"
Write-Output "zona muda entre borde y QR: $mudaMod modulos, minimo 4"
Write-Output "el QR ocupa el $ocupa por ciento del ancho"
