import './App.css';
import React from 'react';

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

export default class MyApp extends React.Component {

  componentDidMount() {
		// TODO: env var
		fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/stations", {
			method:'GET',
		}).then(response => response.json())
			.then(data => { 
				var stationListDiv = document.querySelector("#station-list")
				stationListDiv.innerHTML = ""
				for (const [number, name] of Object.entries(data.pandora)) {
					stationListDiv.innerHTML += "<span style='display:block'>"+number+": "+name+"</span>"
				}
			})
			.catch(console.error)
		// TODO:Handle error status code
  }

  render() {
    return (
      <div className="App">
        <span id="socket-status" style={styles.socketStatusSpan}> </span>
        <div id="station-list"> </div>
      </div>
    );
  }

}
