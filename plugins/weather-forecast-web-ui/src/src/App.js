import './App.css';

import React, { useState, useEffect } from 'react';

const styles = {
	topDiv: {
		marginBottom:-4,
		position:"relative"
	},
	nestedAnchor: {
		position: "absolute", 
		bottom: 0, 
		transform: "translateX(-50%)", 
		left: "50%"
	}
}

function initWeather(d, s, id) {
	if (d.getElementById(id)) {
		if (window.__TOMORROW__) {
			window.__TOMORROW__.renderWidget();
		}
		return;
	}
	const fjs = d.getElementsByTagName(s)[0];
	const js = d.createElement(s);
	js.id = id;
	js.src = "https://www.tomorrow.io/v1/widget/sdk/sdk.bundle.min.js";

	fjs.parentNode.insertBefore(js, fjs);
}

// function makeChanges(document) {
// 		document.getElementsByClassName(".summary-widget__player--zrTG")[0].remove()
// 		var newDiv = document.createElement("div")
// 		newDiv.appendChild(document.getElementsByClassName(".summary-widget__current--Gn1C")[0])
// 		newDiv.appendChild(document.getElementsByClassName(".summary-widget__summary--GH84")[0])
// 		document.getElementsByClassName(".upcoming-widget-horizontal__current--NOo9")[0].replaceWith(newDiv)	
//
// }

function App() {
//  const [count, setCount] = useState(0);

	// Similar to componentDidMount and componentDidUpdate:
	useEffect(() => {
	// 	let observer = new MutationObserver((mutations) => {
	// 		mutations.forEach((mutation) => {
	// 			mutation.addedNodes.forEach((addedNode) => {
	// 				console.log(addedNode.attribute)
	// 				if (addedNode.nodeName == "IFRAME") {
	// 					// let observer2 = new MutationObserver((mutations) => {
	// 					// 	mutation.addedNodes.forEach((addedNode2) => {
	// 					// 		console.log(addedNode2)
	// 					// 	});
	// 					// })
  //
	// 					addedNode.addEventListener("load", function() {
	// 						makeChanges(document)
	// 					});
	// 					// observer2.observe(addedNode.contentDocument.body.parentElement, {
	// 					// 	childList: true
	// 					// 	, subtree: true
	// 					// 	, attributes: false
	// 					// 	, characterData: false
	// 					// })
	// 				}
	// 			})
	// 		})
	// 	})

	// 	observer.observe(document.body, {
	// 		childList: true
	// 		, subtree: true
	// 		, attributes: false
	// 		, characterData: false
	// 	})
    // initWeather(document, 'script', 'tomorrow-sdk')
    var script = document.createElement('script')
    script.src = "https://srv2.weatherwidget.org/js/?id=ww_ddb61fb2b1da9"
    document.body.append(script)

    var script2 = document.createElement('script')
    script2.src = "https://srv2.weatherwidget.org/js/?id=ww_83d29781daf0e"
    document.body.append(script2)

  })

  return (
		<div>
      <div id="ww_83d29781daf0e" v='1.20' loc='id' style={{maxWidth:'440px'}} a='{"t":"responsive","lang":"en","ids":["wl3908"],"cl_bkg":"image","cl_font":"#FFFFFF","cl_cloud":"#FFFFFF","cl_persp":"#81D4FA","cl_sun":"#FFC107","cl_moon":"#FFC107","cl_thund":"#FF5722","sl_tof":"3","sl_sot":"fahrenheit","sl_ics":"one","font":"Arial","el_nme":3}'>Weather Data Source: <a href="https://sharpweather.com/weather_portland/" id="ww_83d29781daf0e_u" target="_blank"  >Portland Weather</a></div>
      <div id="ww_ddb61fb2b1da9" v='1.20' loc='id' a='{"t":"horizontal","lang":"en","ids":["wl3908"],"cl_bkg":"image","cl_font":"#FFFFFF","cl_cloud":"#FFFFFF","cl_persp":"#81D4FA","cl_sun":"#FFC107","cl_moon":"#FFC107","cl_thund":"#FF5722","sl_sot":"fahrenheit","sl_ics":"one","font":"Arial","el_nme":3,"el_cwt":3,"el_phw":3}'>Weather Data Source: <a href="https://sharpweather.com/weather_portland/" id="ww_ddb61fb2b1da9_u" target="_blank">Portland Weather</a></div>

    </div>
  )
}
export default App;
