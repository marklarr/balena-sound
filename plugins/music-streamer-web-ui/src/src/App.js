import './App.css';

const styles = {
  button: {
    justifyContent: 'center',
    marginTop: 20,
    color: 'white',
    borderRadius: 5,
  },
}

console.log(process.env.REACT_APP_BALENA)
const MUSIC_STREAMER_API_ROOT = process.env.REACT_APP_BALENA === "1" ? "192.168.0.23:3434" : "localhost:3434"
console.log("music-streamer api root: " + MUSIC_STREAMER_API_ROOT)

function playLofiHipHopRadio() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/play/lofi_hip_hop_radio", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function stop() {
  // TODO: env var
  fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stop", {
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
        <button style={{...styles.button,...{backgroundColor: 'red'}}}  onClick={stop}> Stop </button>
      </header>
    </div>
  );
}

export default App;
