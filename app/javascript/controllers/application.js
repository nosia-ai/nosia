import { Application } from "@hotwired/stimulus"
import Clipboard from "@stimulus-components/clipboard"
import RevealController from "@stimulus-components/reveal"

const application = Application.start()
application.register('clipboard', Clipboard)
application.register('reveal', RevealController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
