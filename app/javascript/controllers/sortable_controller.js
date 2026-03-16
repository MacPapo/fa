import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
    connect() {
	this.sortable = Sortable.create(this.element, {
	    handle: ".sortable-handle",
	    animation: 150,
	    ghostClass: "opacity-20",
	    onEnd: () => this.updatePositions()
	})

	// Importante: aggiorna se aggiungiamo nuovi elementi dal nested-form
	this.observer = new MutationObserver(() => this.updatePositions())
	this.observer.observe(this.element, { childList: true })

	this.updatePositions()
    }

    disconnect() {
	this.sortable.destroy()
	this.observer.disconnect()
    }

    updatePositions() {
	const rows = Array.from(this.element.children).filter(el => el.tagName !== 'TEMPLATE')

	let currentPosition = 1
	rows.forEach((row) => {
	    const positionInput = row.querySelector('.position-input')
	    const destroyFlag = row.querySelector('.destroy-flag')

	    // Se la riga esiste e non è segnata per la distruzione
	    if (positionInput && (!destroyFlag || destroyFlag.value !== "1")) {
		positionInput.value = currentPosition
		currentPosition++
	    }
	})
    }
}
