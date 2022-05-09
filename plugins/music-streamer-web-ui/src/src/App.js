import './App.css';

const styles = {
  button: {
    justifyContent: 'center',
    marginTop: 20,
    color: 'white',
    borderRadius: 5,
  },

  socketStatusSpan: {
    marginTop: 6
  }
}

console.log(process.env.REACT_APP_BALENA)
const MUSIC_STREAMER_API_ROOT = process.env.REACT_APP_BALENA === "1" ? "192.168.5.227:3434" : "localhost:3434"
console.log("music-streamer api root: " + MUSIC_STREAMER_API_ROOT)
var webSocket = new WebSocket("ws://"+MUSIC_STREAMER_API_ROOT+"/websocket/updates")
webSocket.onmessage = function (e) {
  console.log("From Server: " + e.data);
  document.getElementById("socket-status").innerHTML = e.data
};

function playLofiHipHopRadio() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/youtube", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function nextTrack() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/next_track", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function playPandoraRadio() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/pandora_radio", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function stop() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/stop", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function App() {

  return (
    <div className="App">
      <header className="App-header">
        <button style={{...styles.button,...{backgroundColor: '#007AFF'}}} onClick={playLofiHipHopRadio}> Play Lofi Hip-Hop Radio </button>
        <button style={{...styles.button,...{backgroundColor: '#007AFF'}}} onClick={playPandoraRadio}> Play Pandora Radio </button>
        <button style={{...styles.button,...{backgroundColor: 'Green'}}} onClick={nextTrack}> Skip </button>
        <button style={{...styles.button,...{backgroundColor: 'red'}}}  onClick={stop}> Stop </button>
        <span id="socket-status" style={styles.socketStatusSpan}> </span>
      </header>
    </div>
  );
}

export default App;
