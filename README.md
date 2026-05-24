Harmogram
=============

Audio visualizer originally powered by the Soundcloud API.
- Web Audio API
- Backbone.js
- Paper.js

## Stato attuale e modifiche

Questo repository è stato aggiornato per funzionare in un ambiente moderno senza dipendere esclusivamente dalle API SoundCloud. Di seguito sono riportate le modifiche principali effettuate.

### 1. Problema `eco` mancante

- Il file `eco-compiler.js` richiede il modulo Node `eco`.
- Questo modulo deve essere installato con `npm install` perché non era presente di default.
- Le dipendenze Node sono gestite da `package.json`, che include `eco` come dipendenza.

### 2. Problema `compass`/Ruby

- Lo script `compiler` usa `compass watch` per compilare gli SCSS.
- `compass` dipende da Ruby e non viene installato da `npm`.
- In questo ambiente è stata riscontrata un'incompatibilità con Ruby 3.3/3.4 e `compass 1.0.3`:
  - `undefined method 'exists?' for class File`
- Per far funzionare `compass` servirebbe usare una versione di Ruby compatibile o aggiornare la configurazione Ruby/Compass.

### 3. Uso di una source audio locale gratuita

Per evitare la dipendenza da SoundCloud e permettere riproduzione audio stabile, l'app è stata modificata per usare file audio pubblici gratuiti.

Modifiche chiave:
- `public/js/main.js`
  - rimossa l'inizializzazione `SC.initialize(...)` di SoundCloud.
- `public/js/views/home.js`
  - `fetchTracks()` ora carica una lista `localTracks` invece di chiamare l'API SoundCloud.
  - `localTracks` contiene tracce con `audio_src` puntato a file audio gratuiti esterni.
- `public/js/jst.js`
  - il template audio ora usa `audio_src` quando disponibile.
  - mantiene il comportamento legacy per `stream_url`, ma l'app ora funziona con la sorgente locale.
- `public/index.html`
  - rimosso il caricamento dello SDK SoundCloud per evitare dipendenze non necessarie.
  - aggiornato testo descrittivo per riflettere il nuovo source audio.

## Come eseguire

1. Installa le dipendenze Node:
   ```bash
   npm install
   ```
2. Avvia il progetto:
   ```bash
   npm start
   ```
3. Apri l'app in un browser servendo `public/` con un server locale, ad esempio:
   ```bash
   cd public
   python3 -m http.server 8000
   ```
   Quindi apri `http://localhost:8000`.

## Note importanti

- Le tracce audio sono state aggiornate per usare una fonte gratuita e funzionare in questo Codespace.
- Se vuoi ripristinare il supporto SoundCloud in futuro, sarà necessario ottenere una client ID valida e aggiornare l'integrazione alle API più recenti.

## Salvataggio e commit nel Codespace

Per non perdere le modifiche, esegui questi comandi nel terminale del Codespace:

```bash
cd /workspaces/harmogram23
git status --short
git add public/index.html public/js/main.js public/js/views/home.js public/js/jst.js README.md
git commit -m "Use free sample audio source instead of SoundCloud and document eco/Ruby/Compass setup"
```

Se vuoi inviare le modifiche a GitHub:

```bash
git push origin master
```

Se preferisci lavorare su un branch separato:

```bash
git checkout -b fix/local-audio-source
git push -u origin fix/local-audio-source
```
