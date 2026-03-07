import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-autocomplete"
export default class extends Controller {
    static targets = ["input", "results", "selectedContainer", "badgeTemplate"]
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

	// Evita duplicati
	if (this.selectedContainerTarget.querySelector(`[data-id="${id}"]`)) {
	    this.resetSearch()
	    return
	}

	// Prendi il template HTML e sostituisci i placeholder
	let templateHtml = this.badgeTemplateTarget.innerHTML
	templateHtml = templateHtml.replaceAll("TEMPLATE_ID", id)
	templateHtml = templateHtml.replaceAll("TEMPLATE_NAME", name)

	// Aggiungi il nuovo badge al contenitore
	this.selectedContainerTarget.insertAdjacentHTML('beforeend', templateHtml)

	this.resetSearch()
    }

    remove(event) {
	// Rimuove il badge genitore (e l'input hidden al suo interno)
	event.currentTarget.closest(".badge").remove()
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
