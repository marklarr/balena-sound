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

const params = new Proxy(new URLSearchParams(window.location.search), {
  get: (searchParams, prop) => searchParams.get(prop),
});

let audio_stream_source = params.audio_stream_source

console.log(process.env.REACT_APP_BALENA)
const MUSIC_STREAMER_API_ROOT = process.env.REACT_APP_BALENA === "1" ? "192.168.5.227:3434" : "localhost:3434"
console.log("music-streamer api root: " + MUSIC_STREAMER_API_ROOT)

if (!audio_stream_source || audio_stream_source.length == 0) {
  var webSocket = new WebSocket("ws://"+MUSIC_STREAMER_API_ROOT+"/websocket/updates")
  webSocket.onmessage = function (e) {
    console.log("From Server: " + e.data);
    document.getElementById("socket-status").innerHTML = e.data
  };
}

export default class MyApp extends React.Component {

  componentDidMount() {
    if (!audio_stream_source || audio_stream_source.length == 0) {
      return
    }
		// TODO: env var
    fetch("http://" + MUSIC_STREAMER_API_ROOT + "/stream/"+audio_stream_source+"/stations", {
			method:'GET',
		}).then(response => response.json())
			.then(data => { 
				var stationListDiv = document.querySelector("#station-list")
				stationListDiv.innerHTML = ""
				for (const [number, name] of Object.entries(data)) {
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
