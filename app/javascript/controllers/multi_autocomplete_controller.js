import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-autocomplete"
export default class extends Controller {
	// selectedContainer: dove appendiamo le nuove righe
	// badgeTemplate: il pezzo di HTML nascosto da clonare
	static targets = ["input", "results", "selectedContainer", "badgeTemplate"]
	static values = { url: String }

	connect() {
		this.timeout = null
		this.handleModalSuccess = this.handleModalSuccess.bind(this)
		window.addEventListener("modal:success", this.handleModalSuccess)
	}

	disconnect() {
		window.removeEventListener("modal:success", this.handleModalSuccess)
	}

	handleModalSuccess(event) {
		if (event.detail.modalId === this.element.dataset.modalId) {
			this.inputTarget.value = "" // ...Svuotala!
		}
	}

	search() {
		clearTimeout(this.timeout)
		const query = this.inputTarget.value

		if (query.length < 2) {
			this.resultsTarget.innerHTML = ""
			return
		}

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

		const id = event.currentTarget.dataset.id
		const name = event.currentTarget.dataset.name

		// Generiamo un ID univoco basato sul timestamp per i nested attributes di Rails
		const uniqueKey = new Date().getTime()

		// 1. Prendi il template HTML e sostituisci le variabili magiche
		let templateHtml = this.badgeTemplateTarget.innerHTML
		templateHtml = templateHtml.replace(/NEW_RECORD/g, uniqueKey)
		templateHtml = templateHtml.replace(/TEMPLATE_ID/g, id)
		templateHtml = templateHtml.replace(/TEMPLATE_NAME/g, name)

		// 2. Aggiungi la nuova riga al contenitore visibile
		this.selectedContainerTarget.insertAdjacentHTML('beforeend', templateHtml)

		// 3. Resetta la barra di ricerca per cercare un'altra persona
		this.inputTarget.value = ""
		this.resultsTarget.innerHTML = ""
	}

	removeRow(event) {
		event.preventDefault()

		const row = event.currentTarget.closest('.participation-row') || event.currentTarget.closest('.badge')
		if (!row) return

		const destroyFlag = row.querySelector('.destroy-flag')

		if (destroyFlag) {
			destroyFlag.value = "1"
			row.style.display = 'none'
		} else {
			row.remove()
		}
	}

	openModal(event) {
		event.preventDefault()

		const modalId = this.element.dataset.modalId
		const inputId = this.element.dataset.inputId
		const currentQuery = this.inputTarget.value

		const modal = document.getElementById(modalId)
		const nameInput = document.getElementById(inputId)

		if (modal) {
			if (nameInput) nameInput.value = currentQuery
			modal.showModal()
			this.resultsTarget.innerHTML = ""
		}
	}
}
