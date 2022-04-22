import './App.css';

const styles = {
  button: {
    justifyContent: 'center',
    marginTop: 20,
    color: 'white',
    borderRadius: 5,
  },
}

function playLofiHipHopRadio() {
  // TODO: env var
  fetch("http://192.168.0.23:3434/play/lofi_hip_hop_radio", {
    method:'POST',
    mode: 'no-cors'
  }).catch(console.error)
  // TODO:Handle error status code
}

function stop() {
  // TODO: env var
  fetch("http://192.168.0.23:3434/stop", {
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
