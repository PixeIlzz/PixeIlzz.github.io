window.__CHECK2 = function(url, marginMods){
  var q = QR.makeQR(url,'H');
  var im = document.getElementById('a');
  if(!im.complete || !im.naturalWidth) return {error:'imagen no cargada'};
  var n = q.n, W = im.naturalWidth;
  var s = W / (n + 2*marginMods);

  // --- alfa crudo, sin componer: confirma que el fondo es transparente ---
  var craw = document.createElement('canvas');
  craw.width = W; craw.height = W;
  var xr = craw.getContext('2d');
  xr.clearRect(0,0,W,W);
  xr.drawImage(im,0,0);
  var draw = xr.getImageData(0,0,W,W).data;
  function alphaAt(px,py){ return draw[(py*W+px)*4+3]; }
  var esquina = alphaAt(2,2);
  // punto en la zona muda, entre el borde y el QR
  var quietPx = Math.floor((marginMods - 0.5)*s);
  var alfaMuda = alphaAt(quietPx, Math.floor(W/2));
  var opacos = 0, total = 0;
  for (var yy=0; yy<W; yy+=7){ for (var xx=0; xx<W; xx+=7){ total++; if (draw[(yy*W+xx)*4+3] > 200) opacos++; } }

  // --- compuesto sobre blanco, que es como se va a usar ---
  var c = document.createElement('canvas');
  c.width = W; c.height = W;
  var x = c.getContext('2d');
  x.fillStyle = '#ffffff'; x.fillRect(0,0,W,W);
  x.drawImage(im,0,0);
  var d = x.getImageData(0,0,W,W).data;

  var mR = [], rows = [];
  for(var i=0;i<n;i++){ mR[i]=[]; var r='';
    for(var j=0;j<n;j++){
      var px = Math.floor((j+marginMods)*s + s/2), py = Math.floor((i+marginMods)*s + s/2);
      var o = (py*W+px)*4;
      var v = ((0.299*d[o]+0.587*d[o+1]+0.114*d[o+2]) < 128) ? 1 : 0;
      mR[i][j]=v; r+=v; }
    rows.push(r); }

  // --- comparacion fuera de la zona del logo ---
  var exp = QR.rowsOf(q).rows;
  var lo = 9, a0 = Math.floor((n-lo)/2), a1 = a0+lo-1;
  var fuera=0, malFuera=[];
  for(var i=0;i<n;i++) for(var j=0;j<n;j++){
    if (i>=a0 && i<=a1 && j>=a0 && j<=a1) continue;
    fuera++;
    if (String(mR[i][j]) !== exp[i][j]) malFuera.push('('+i+','+j+')');
  }

  // --- capacidad Reed-Solomon bloque a bloque ---
  var got=[], bit=0, cur=0;
  q.order.forEach(function(k){
    var p=k.split(','), r=+p[0], cc=+p[1], v=mR[r][cc];
    if(QR._mask(q.mask,r,cc)) v^=1;
    cur=(cur<<1)|v; bit++;
    if(bit===8){ got.push(cur); cur=0; bit=0; } });
  var bl=q.enc.blocks, nb=bl.length, nec=q.enc.nec, maxD=0, maxE=0;
  bl.forEach(function(b){ maxD=Math.max(maxD,b.d.length); maxE=Math.max(maxE,b.e.length); });
  var gd=bl.map(function(){return [];}), ge=bl.map(function(){return [];}), p2=0;
  for(var i=0;i<maxD;i++) for(var b=0;b<nb;b++) if(i<bl[b].d.length) gd[b].push(got[p2++]);
  for(var i=0;i<maxE;i++) for(var b=0;b<nb;b++) if(i<bl[b].e.length) ge[b].push(got[p2++]);
  var t=Math.floor(nec/2), det=[], peor=0;
  for(var b=0;b<nb;b++){
    var err=0;
    for(var i=0;i<bl[b].d.length;i++) if(gd[b][i]!==bl[b].d[i]) err++;
    for(var i=0;i<bl[b].e.length;i++) if(ge[b][i]!==bl[b].e[i]) err++;
    if(err>peor) peor=err;
    det.push('bloque '+b+': '+err+'/'+t);
  }

  return {
    px:W, modulo:Math.round(s), margenModulos:marginMods,
    alfaEsquina:esquina, alfaZonaMuda:alfaMuda,
    pctOpaco:(100*opacos/total).toFixed(1),
    modulosFuera:fuera, erroresFuera:malFuera.length, primeros:malFuera.slice(0,6),
    bloques:det, peorBloque:peor, capacidad:t, margenRS:(t-peor),
    todoOK:(malFuera.length===0 && peor<=t && esquina===0)
  };
};
