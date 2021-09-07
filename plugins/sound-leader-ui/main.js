const { app, BrowserWindow } = require('electron')


function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}   

async function getPandoraStationsHtml () {
  const win = new BrowserWindow({
    show: true,
  })

  win.loadURL('https://www.pandora.com/collection/stations')
  await sleep(10000)

  return win.webContents.executeJavaScript('Array.from(document.querySelectorAll("div.GridItem__metaInfo > div > div.GridItem__caption__main > a")).map(function(e) { e.href = e.href; e.target = "audio-player-iframe"; return e.outerHTML})') }

async function createWindow () {
  const win = new BrowserWindow({
    width: 600,
    height: 800,
    webPreferences: { 
      webSecurity: false, 
      nodeIntegration: true,
      contextIsolation: false,
    }
  })

  pandoraStationsHtml = await getPandoraStationsHtml()
  pandoraStationsHtml += "<iframe name='audio-player-iframe'></iframe>"
  // create BrowserWindow with dynamic HTML content
  win.loadURL("data:text/html;charset=utf-8," + encodeURI(pandoraStationsHtml));
  win.webContents.session.webRequest.onHeadersReceived({ urls: [ "*://*/*" ] },
      (d, c)=>{
        if(d.responseHeaders['X-Frame-Options']){
          delete d.responseHeaders['X-Frame-Options'];
        } else if(d.responseHeaders['x-frame-options']) {
          delete d.responseHeaders['x-frame-options'];
        }

        c({cancel: false, responseHeaders: d.responseHeaders});
      })
}

app.whenReady().then(() => {
app.commandLine.appendSwitch('--disable-web-security')
  createWindow()
})
