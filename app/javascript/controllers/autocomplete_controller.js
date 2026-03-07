import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
	// input: il campo dove scrivi
	// hidden: il campo che invia l'ID al server
	// results: il div a tendina dove iniettiamo l'HTML
	static targets = ["input", "hidden", "results"]
	static values = { url: String }

	connect() {
		this.timeout = null
	}

	search() {
		clearTimeout(this.timeout)
		const query = this.inputTarget.value

		if (query.length < 2) {
			this.resultsTarget.innerHTML = ""
			return
		}

		// Debounce: aspetta 300ms prima di chiamare il server per non intasarlo
		this.timeout = setTimeout(() => {
			fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`)
				.then(response => response.text())
				.then(html => {
					this.resultsTarget.innerHTML = html
				})
		}, 300)
	}

	select(event) {
		event.preventDefault()

		// 1. Popola i campi
		this.hiddenTarget.value = event.currentTarget.dataset.id
		this.inputTarget.value = event.currentTarget.dataset.name

		// 2. Chiudi la tendina
		this.resultsTarget.innerHTML = ""
	}

	openModal(event) {
		event.preventDefault()

		// Legge l'ID del modale direttamente dal fieldset genitore
		const modalId = this.element.dataset.modalId
		const inputId = this.element.dataset.inputId
		const currentQuery = this.inputTarget.value

		const modal = document.getElementById(modalId)
		const nameInput = document.getElementById(inputId)

		if (modal) {
			if (nameInput) nameInput.value = currentQuery
			modal.showModal()
			this.resultsTarget.innerHTML = ""
		} else {
			console.error("Modale non trovato:", modalId)
		}
	}
}
