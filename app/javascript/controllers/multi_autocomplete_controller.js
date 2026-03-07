import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-autocomplete"
export default class extends Controller {
	static targets = ["input", "results", "selectedContainer", "badgeTemplate"]
	static values = {
		url: String,
		role: String
	}

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

		// Evita duplicati visivi (controlliamo gli input hidden contact_id)
		const existingInputs = Array.from(this.selectedContainerTarget.querySelectorAll('input[name$="[contact_id]"]'))
		if (existingInputs.some(input => input.value === id && !input.closest('.participation-row').classList.contains('hidden'))) {
			this.resetSearch()
			return
		}

		// Generiamo un ID univoco per il nested form (il timestamp in millisecondi è perfetto)
		const uniqueIndex = new Date().getTime()

		// Costruiamo l'HTML
		let templateHtml = this.badgeTemplateTarget.innerHTML
		templateHtml = templateHtml.replaceAll("NEW_RECORD", uniqueIndex)
		templateHtml = templateHtml.replaceAll("TEMPLATE_ID", id)
		templateHtml = templateHtml.replaceAll("TEMPLATE_NAME", name)

		// Aggiungiamo la riga
		this.selectedContainerTarget.insertAdjacentHTML('beforeend', templateHtml)
		this.resetSearch()
	}

	removeRow(event) {
		const row = event.currentTarget.closest(".participation-row")
		const destroyFlag = row.querySelector(".destroy-flag")

		if (destroyFlag) {
			// Segniamo il record per l'eliminazione da parte di Rails
			destroyFlag.value = "1"
			// Nascondiamo la riga visivamente
			row.classList.add("hidden")
		} else {
			// Era un record nuovo mai salvato, possiamo rimuoverlo dal DOM
			row.remove()
		}
	}

	resetSearch() {
		this.inputTarget.value = ""
		this.resultsTarget.innerHTML = ""
	}

	// La logica del modale rimane IDENTICA al single-select
	openModal(event) {
		event.preventDefault()
		const query = event.currentTarget.dataset.query
		const modalId = event.currentTarget.dataset.modalId
		const inputId = event.currentTarget.dataset.inputId

		const modal = document.getElementById(modalId)
		const nameInput = document.getElementById(inputId)

		if (modal && nameInput) {
			nameInput.value = query
			modal.showModal()
			this.resultsTarget.innerHTML = ""
		}
	}
}
