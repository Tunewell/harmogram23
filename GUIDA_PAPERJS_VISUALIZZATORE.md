# Guida Completa: Creare un Visualizzatore Audio con Paper.js e Web Audio API

Questa guida ti insegna come costruire il visualizzatore audio di Harmogram **pezzettino per pezzettino**.

---

## Parte 1: Concetti Base

### 1.1 Cos'è Paper.js?

`paper.js` è una libreria JavaScript per grafica vettoriale su canvas HTML5.

Permette di:
- Creare forme (Path, Rectangle, Circle)
- Gestire punti (Point)
- Disegnare automaticamente
- Aggiornare la vista in tempo reale

**Installa paper.js:**
```html
<script src="js/paper.js"></script>
<canvas id="myCanvas" resize></canvas>
```

### 1.2 Cos'è Web Audio API?

La Web Audio API ti permette di:
- Leggere i dati audio (frequenze, amplitudini)
- Processare suono
- Creare effetti audio

Userai `AudioContext` e `Analyser` per ottenere i dati di frequenza.

---

## Parte 2: Setup Iniziale

### Step 1: Crea il Canvas HTML

```html
<!DOCTYPE html>
<html>
<head>
    <title>Audio Visualizer</title>
    <style>
        canvas {
            display: block;
            width: 100%;
            height: 100vh;
        }
    </style>
</head>
<body>
    <canvas id="myCanvas" resize></canvas>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/paper.js/0.12.15/paper-full.min.js"></script>
    <script src="app.js"></script>
</body>
</html>
```

**Cosa fa:**
- `<canvas id="myCanvas" resize>`: crea il canvas che paper.js userà.
- `resize` fa sì che il canvas si adatti al resize della finestra.

### Step 2: Inizializza Paper.js

```javascript
// Seleziona il canvas
var canvas = document.getElementById('myCanvas');

// Inizializza paper.js
paper.setup(canvas);

// Disegna una volta per inizializzare la vista
paper.view.draw();
```

**Cosa fa:**
- `paper.setup(canvas)` prepara paper.js a usare il canvas.
- `paper.view.draw()` ridisegna la scena.

---

## Parte 3: Creare la Forma Base

### Step 3: Crea una forma con Paper.js

Vogliamo creare una forma che oscillerà con l'audio. Iniziamo con una forma vuota:

```javascript
// Crea un percorso (Path)
var path = new paper.Path();
path.closed = false;  // Non chiudere il percorso
path.strokeColor = 'black';
path.strokeWidth = 2;

// Aggiungi punti iniziali
var numBars = 256;  // Quanti segmenti avrà la forma
var centerX = paper.view.center.x;
var centerY = paper.view.center.y;
var baseRadius = 50;  // Raggio iniziale

for (var i = 0; i < numBars; i++) {
    // Converti da indice a angolo in radianti
    var angle = (i / numBars) * Math.PI * 2;
    
    // Calcola le coordinate usando seno/coseno
    var x = centerX + Math.cos(angle) * baseRadius;
    var y = centerY + Math.sin(angle) * baseRadius;
    
    // Aggiungi il punto alla forma
    path.add(new paper.Point(x, y));
}

// Disegna
paper.view.draw();
```

**Cosa fa:**
- Crea 256 punti disposti in cerchio
- Usa `seno` e `coseno` per posizionare i punti in coordinate polari
- Il primo loop crea il cerchio iniziale

**Risultato:** Un cerchio nero disegnato sullo schermo.

---

## Parte 4: Setup Web Audio API

### Step 4: Connetti l'audio al Web Audio API

```javascript
// Crea un contesto audio
var audioContext = new (window.AudioContext || window.webkitAudioContext)();

// Crea un analizzatore (legge i dati audio)
var analyser = audioContext.createAnalyser();

// Connetti l'analizzatore all'output audio
analyser.connect(audioContext.destination);

// Imposta la risoluzione (numero di barre di frequenza)
analyser.fftSize = 512;  // Fornirà 256 valori

// Array dove salverai i dati di frequenza
var freqData = new Uint8Array(analyser.frequencyBinCount);
```

**Cosa fa:**
- `AudioContext` è il "motore" audio
- `analyser` legge i dati di frequenza dell'audio
- `fftSize` determina quanti dati leggi (512 = 256 barre)
- `freqData` sarà un array con i valori di frequenza (0-255)

### Step 5: Connetti un elemento audio all'analizzatore

```javascript
// Assume che hai un elemento audio in HTML:
// <audio id="myAudio" src="song.mp3"></audio>

var audioElement = document.getElementById('myAudio');

// Crea una source dal file audio
var source = audioContext.createMediaElementSource(audioElement);

// Connetti il file audio all'analizzatore
source.connect(analyser);

// Dichiara il crossOrigin per supportare i file remoti
audioElement.crossOrigin = "anonymous";

// Avvia la riproduzione
audioElement.play();
```

**Cosa fa:**
- Prende il file audio dal DOM
- Lo connette all'analizzatore
- Ogni volta che suona, `analyser` avrà i dati aggiornati

---

## Parte 5: Aggiornare la Forma in Base all'Audio

### Step 6: Leggi i dati audio e aggiorna i punti

```javascript
// Funzione che aggiorna la forma in base all'audio
function updateVisualization() {
    // Leggi i dati di frequenza correnti
    analyser.getByteFrequencyData(freqData);
    
    // Per ogni barra di frequenza
    for (var i = 0; i < numBars; i++) {
        // Prendi il valore di frequenza (0-255)
        var magnitude = freqData[i];
        
        // Normalizza il valore
        // Dividi per 255 per ottenere un valore 0-1
        var normalizedMagnitude = magnitude / 255;
        
        // Calcola il nuovo raggio (più grande = più audio)
        var newRadius = baseRadius + (normalizedMagnitude * 100);
        
        // Calcola l'angolo di questo punto
        var angle = (i / numBars) * Math.PI * 2;
        
        // Calcola le nuove coordinate
        var x = centerX + Math.cos(angle) * newRadius;
        var y = centerY + Math.sin(angle) * newRadius;
        
        // Aggiorna il punto nel percorso
        path.segments[i].point.x = x;
        path.segments[i].point.y = y;
    }
    
    // Liscia i punti per una forma più morbida
    path.smooth();
    
    // Ridisegna il canvas
    paper.view.draw();
    
    // Chiama questa funzione di nuovo al prossimo frame
    requestAnimationFrame(updateVisualization);
}

// Inizia l'aggiornamento
updateVisualization();
```

**Cosa fa:**
- `analyser.getByteFrequencyData(freqData)` legge i dati audio in tempo reale
- Per ogni punto della forma, prende il valore di frequenza corrispondente
- Moltiplica quel valore per un fattore di scala (100)
- Aggiorna la posizione del punto
- `path.smooth()` rende la forma morbida
- `requestAnimationFrame` richiama la funzione 60 volte al secondo

**Risultato:** Il cerchio oscilla in base ai suoni!

---

## Parte 6: Aggiungere Effetti Visivi

### Step 7: Cambia il colore in base al suono

```javascript
function updateVisualization() {
    analyser.getByteFrequencyData(freqData);
    
    // Calcola l'ampiezza media
    var totalAmplitude = 0;
    for (var i = 0; i < freqData.length; i++) {
        totalAmplitude += freqData[i];
    }
    var averageAmplitude = totalAmplitude / freqData.length;
    
    // Normalizza tra 0 e 100
    var brightness = (averageAmplitude / 255) * 100;
    
    // Cambia il colore della linea in base al suono
    var hue = 42;  // Tonalità fissa
    var saturation = 70;  // Saturazione
    path.strokeColor = `hsl(${hue}, ${saturation}%, ${brightness}%)`;
    
    // ... resto del codice per aggiornare i punti ...
}
```

**Cosa fa:**
- Calcola l'ampiezza media di tutti i dati audio
- Usa HSL (Hue, Saturation, Lightness) per il colore
- La luminosità (`lightness`) cambia con l'audio

### Step 8: Ruota la forma

```javascript
var baseAngle = 0;
var rotationSpeed = 0.0001618;  // Numero aureo!

function updateVisualization() {
    analyser.getByteFrequencyData(freqData);
    
    // Incrementa l'angolo per rotare
    baseAngle += rotationSpeed;
    
    for (var i = 0; i < numBars; i++) {
        var magnitude = freqData[i];
        var normalizedMagnitude = magnitude / 255;
        var newRadius = baseRadius + (normalizedMagnitude * 100);
        
        // Usa baseAngle per ruotare tutto
        var angle = baseAngle + (i / numBars) * Math.PI * 2;
        
        var x = centerX + Math.cos(angle) * newRadius;
        var y = centerY + Math.sin(angle) * newRadius;
        
        path.segments[i].point.x = x;
        path.segments[i].point.y = y;
    }
    
    path.smooth();
    paper.view.draw();
    requestAnimationFrame(updateVisualization);
}
```

**Cosa fa:**
- `baseAngle` è un angolo che aumenta continuamente
- Aggiungendo a `angle`, tutto il percorso ruota
- La rotazione è costante ma fluida

---

## Parte 7: Codice Completo Finale

```javascript
// Inizializza paper.js
var canvas = document.getElementById('myCanvas');
paper.setup(canvas);

// Setup Web Audio API
var audioContext = new (window.AudioContext || window.webkitAudioContext)();
var analyser = audioContext.createAnalyser();
analyser.connect(audioContext.destination);
analyser.fftSize = 512;
var freqData = new Uint8Array(analyser.frequencyBinCount);

// Connetti elemento audio
var audioElement = document.getElementById('myAudio');
var source = audioContext.createMediaElementSource(audioElement);
source.connect(analyser);
audioElement.crossOrigin = "anonymous";

// Crea la forma
var path = new paper.Path();
path.closed = false;
path.strokeColor = 'black';
path.strokeWidth = 2;

var numBars = 256;
var centerX = paper.view.center.x;
var centerY = paper.view.center.y;
var baseRadius = 50;
var baseAngle = 0;
var rotationSpeed = 0.0001618;

// Inizializza i punti
for (var i = 0; i < numBars; i++) {
    var angle = (i / numBars) * Math.PI * 2;
    var x = centerX + Math.cos(angle) * baseRadius;
    var y = centerY + Math.sin(angle) * baseRadius;
    path.add(new paper.Point(x, y));
}

// Loop principale
function updateVisualization() {
    analyser.getByteFrequencyData(freqData);
    
    // Calcola ampiezza media
    var totalAmplitude = 0;
    for (var i = 0; i < freqData.length; i++) {
        totalAmplitude += freqData[i];
    }
    var averageAmplitude = totalAmplitude / freqData.length;
    var brightness = (averageAmplitude / 255) * 100;
    
    // Cambia colore
    path.strokeColor = `hsl(42, 70%, ${brightness}%)`;
    
    // Aumenta angolo per rotazione
    baseAngle += rotationSpeed;
    
    // Aggiorna ogni punto
    for (var i = 0; i < numBars; i++) {
        var magnitude = freqData[i];
        var normalizedMagnitude = magnitude / 255;
        var newRadius = baseRadius + (normalizedMagnitude * 100);
        
        var angle = baseAngle + (i / numBars) * Math.PI * 2;
        var x = centerX + Math.cos(angle) * newRadius;
        var y = centerY + Math.sin(angle) * newRadius;
        
        path.segments[i].point.x = x;
        path.segments[i].point.y = y;
    }
    
    path.smooth();
    paper.view.draw();
    requestAnimationFrame(updateVisualization);
}

// Avvia
audioElement.play();
updateVisualization();
```

---

## Parte 8: Spiegazione del Codice di Harmogram

Nel progetto reale, il codice è organizzato in **classi separate**:

### `sounder.js` - Web Audio API
```javascript
SounderControl.prototype.init = function() {
    this.context = new AudioContext();
    this.analyser = this.context.createAnalyser();
    this.analyser.connect(this.context.destination);
};

SounderControl.prototype.plugMany = function() {
    $('audio').each((function(_this) {
        return function(plug) {
            var source = _this.context.createMediaElementSource(plug);
            source.connect(_this.analyser);
        };
    }));
};
```
**Le stesse cose che abbiamo fatto, ma riusabili.**

### `renderer.js` - La forma principale
```javascript
Renderer.prototype.initPaper = function() {
    paper.setup(this.$CANVAS[0]);
    this.path = new paper.Path();
    this.path.strokeColor = 'black';
    this.initPoints();
};

Renderer.prototype.shader = function(value) {
    for (var i = 0; i < this.BARS; i++) {
        var magnitude = value[i] * (1.618 * (this.ampVal / 10));
        var x = centerX + Math.cos(angle) * (baseRadius + magnitude);
        var y = centerY + Math.sin(angle) * (baseRadius + magnitude);
        this.path.segments[i].point.x = x;
        this.path.segments[i].point.y = y;
    }
    this.path.smooth();
    paper.view.draw();
};
```

**Importante:**
- `shader()` riceve l'array di dati audio
- Aggiorna i punti della forma
- È la stessa logica che ti ho mostrato, ma in una classe riusabile

---

## Cosa Abbiamo Imparato

1. **Paper.js**: Creare forme vettoriali e aggiornarle in tempo reale
2. **Web Audio API**: Leggere i dati audio con `analyser`
3. **Coordinate Polari**: Usare seno/coseno per disegnare in cerchio
4. **Animazione**: Usare `requestAnimationFrame` per 60fps
5. **Interattività**: Cambiare colore e rotazione in base all'audio

---

## Esercizi per Praticare

1. **Cambia i colori**: Modifica `hsl` per creare altri effetti
2. **Aggiungi più forme**: Crea labirinti concentrici
3. **Cambia la velocità**: Modifica `rotationSpeed`
4. **Usa diverse frequenze**: Dividi `freqData` in bande basse/medie/alte
5. **Aggiungi interattività**: Usa il mouse per controllare parametri

---

Buon divertimento con il tuo visualizzatore audio!
