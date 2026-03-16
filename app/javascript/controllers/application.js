import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

window.Turbo.StreamActions.trigger_event = function() {
    const name = this.getAttribute("name")
    const detail = JSON.parse(this.getAttribute("detail") || "{}")

    const event = new CustomEvent(name, {
	bubbles: true,
	detail: detail
    })

    // Spara l'evento a livello globale su window
    window.dispatchEvent(event)
}

export { application }
