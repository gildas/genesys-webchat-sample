if (!window._genesys)                    window._genesys = {}
if (!window._genesys.widgets)            window._genesys.widgets = {}
if (!window._genesys.widgets.extensions) window._genesys.widgets.extensions = {}

/**
 * Registers the Sample Extension with the GENESYS Widget
 * This code is automatically called by the GENESYS framework
 */
window._genesys.widgets.extensions['Sample'] = function($, CXBus, Common) {
  let plugin = CXBus.registerPlugin('Sample')

  // Register the command version, so the extension can tell its version
  // Usage (in JS console): await CXBus.command('Sample.version')
  plugin.registerCommand('version', function(e) {
    // This version should be incremented every time a new release is deployed
    // @see https://semver.org for proper versioning
    // If you use git flow, a hook increments this automatically when you type `git flow release start`
    var version = '1.1.0'

    Log(`Version: ${version}`)
    return e.deferred.resolve(version)
  })

  // Subscribe to WebChat.opened, so we can add our button in the menu bar
  // when the chat is opened
  plugin.subscribe('WebChat.opened', function (e) {
    AddFortuneMenuItem(document.getElementsByClassName("cx-menu")[0])
  })

  // Subscribe to WebChatService.ended, so we can hide our button
  plugin.subscribe('WebChatService.ended', function (e) {
    document.getElementById('fortune').style['display'] = 'none'
  })

  // Register a command for other extensions to call us
  plugin.registerCommand('fortune', async function(e) {
    try {
      e.deferred.resolve(GetFortune())
    } catch (err) {
      e.deferred.reject(err)
    }
  })

  plugin.republish('ready') // Tell other extensions they can load asynchronously
  plugin.ready()            // Tell the Framework we are ready to do our job
}

/**
 * Retrieves a UNIX fortune(6) cookie
 *
 * @returns {String} the fortune cookie
 * @see https://linux.die.net/man/6/fortune
 * @see https://en.wikipedia.org/wiki/Fortune_(Unix)
 */
async function GetFortune() {
    let response = await fetch('https://api.ef.gy/fortune')
    if (response.ok) {
        return await response.text()
    } else {
        throw response.statusText
    }
}

/**
 * Adds a button to the Widget's menu
 *
 * @param {Element} menu 
 */
function AddFortuneMenuItem(menu) {
  // cxMenuItem is the menu item (<li>) that contains the button
  let cxMenuItem = document.createElement("li")
  cxMenuItem.className = "cx-icon i18n"
  cxMenuItem.setAttribute("tabindex", 0)
  cxMenuItem.setAttribute("id", "fortune")
  cxMenuItem.setAttribute("title", "Get a Fortune Cookie")
  cxMenuItem.style.display = "block"
  // This icon comes from https://www.svgrepo.com/svg/104981/crystal-ball
  cxMenuItem.innerHTML = `
<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" viewBox="0 0 297 297" style="enable-background:new 0 0 297 297;">
  <g>
  <path class="cx-svg-icon-tone1"
    d="M148.5,38.098c-40.931,0-74.231,33.3-74.231,74.23c0,5.887,4.774,10.66,10.66,10.66c5.888,0,10.661-4.773,10.661-10.66
       c0-29.174,23.735-52.91,52.909-52.91c5.887,0,10.66-4.772,10.66-10.66C159.16,42.871,154.387,38.098,148.5,38.098z"
  />
  <path class="cx-svg-icon-tone1"
    d="M282.079,284.249l-17.59-87.946c-0.996-4.983-5.371-8.57-10.453-8.57h-22.362c18.104-19.948,29.154-46.407,29.154-75.404
       C260.828,50.391,210.437,0,148.5,0S36.172,50.391,36.172,112.328c0,28.997,11.051,55.456,29.154,75.404H42.964
       c-5.081,0-9.457,3.587-10.453,8.57l-17.59,87.946c-0.626,3.132,0.185,6.38,2.209,8.85c2.025,2.47,5.051,3.901,8.244,3.901h246.252
       c3.193,0,6.219-1.432,8.244-3.901C281.894,290.629,282.706,287.381,282.079,284.249z M57.492,112.328
       c0-50.183,40.825-91.008,91.008-91.008s91.008,40.825,91.008,91.008c0,31.358-15.954,59.038-40.16,75.404H97.652
       C73.446,171.366,57.492,143.686,57.492,112.328z M38.378,275.68l13.325-66.627h193.594l13.325,66.627H38.378z"
  />
  </g>
</svg>
`
  cxMenuItem.onclick = async function(event) {
    try {
      let message = await GetFortune()

      await CXBus.command('WebChatService.sendMessage', { message }) // sends the message to the transcript
    } catch(err) {
      console.error(err)
    }
  }

  // Insert the button after the emoji button
  if (menu.childNodes.length > 2) {
    menu.insertBefore(cxMenuItem, menu.childNodes[2])
  } else if (menu.childNodes.length > 1) {
    menu.insertBefore(cxMenuItem, menu.childNodes[1])
  } else {
    menu.appendChild(cxMenuItem)
  }
}
