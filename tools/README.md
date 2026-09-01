# tools

Utilidades de desarrollo. No forman parte del sitio: nada en `index.html`
enlaza aqui.

## qr-generator.html

Codificador QR autocontenido, sin dependencias. Abrelo en un navegador y usa
la consola:

    QR.makeQR("https://pixeilzz.github.io", "H")   // niveles: M, Q, H
    QR.verify(q, "https://pixeilzz.github.io")     // 7 comprobaciones
    QR.rowsOf(q)                                   // matriz + checksums

`verify` comprueba sindromes Reed-Solomon, relectura de la matriz,
round-trip del payload, format info y patrones localizadores.

## qr-matrix-H.txt

Matriz ya verificada de `https://pixeilzz.github.io` en nivel H (33x33).
Es la fuente de `qr.png` y `qr-simple.png`.

Render actual: modulos marino #17253C sobre ambar #FFC107, esquinas
redondeadas (radio 0.22 modulos en datos, 0.85 en localizadores).
Radios mayores en los localizadores pierden los modulos de las esquinas.
