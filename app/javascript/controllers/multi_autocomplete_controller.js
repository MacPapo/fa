// app/javascript/controllers/multi_autocomplete_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "selectedContainer", "badgeTemplate"]

    connect() {
	// Leghiamo il listener all'evento globale
	this.boundResetAfterCreate = this.resetAfterCreate.bind(this)
	window.addEventListener("modal:success", this.boundResetAfterCreate)
    }

    disconnect() {
	window.removeEventListener("modal:success", this.boundResetAfterCreate)
    }

    resetAfterCreate() {
	// Se l'input non è nel DOM, ignoriamo
	if (!this.hasInputTarget) return

	this.inputTarget.value = ""
	const frame = this.element.querySelector("turbo-frame")
	if (frame) {
	    frame.innerHTML = ""
	    frame.removeAttribute("src")
	}
	// UX: rimette il focus sull'input per inserire subito un altro contatto!
	this.inputTarget.focus()
    }

    select(event) {
        event.preventDefault()

        const id = event.currentTarget.dataset.id
        const name = event.currentTarget.dataset.name
        const uniqueKey = new Date().getTime()

        let templateHtml = this.badgeTemplateTarget.innerHTML
        templateHtml = templateHtml.replace(/NEW_RECORD/g, uniqueKey)
        templateHtml = templateHtml.replace(/TEMPLATE_ID/g, id)
        templateHtml = templateHtml.replace(/TEMPLATE_NAME/g, name)

        this.selectedContainerTarget.insertAdjacentHTML('beforeend', templateHtml)

        // Resetta l'input per la prossima ricerca
        this.inputTarget.value = ""

        // Svuota e disconnette il frame dei risultati per nascondere il menu
        const frame = this.element.querySelector("turbo-frame")
        if (frame) {
            frame.innerHTML = ""
            frame.removeAttribute("src")
        }

        // UX: Gestione intelligente del Focus
        // Se l'evento è un click del mouse reale (pointerType === "mouse"), chiudiamo il menu togliendo il focus.
        // Se è stato innescato via codice (tastiera), manteniamo il focus per inserimenti multipli veloci.
        // Nota: se il pointerType non è supportato, di default facciamo focus.
        if (event.pointerType === "mouse" || event.pointerType === "touch") {
            this.inputTarget.blur()

            // Hack opzionale per DaisyUI: forza la chiusura chiudendo il details se usi <details class="dropdown">
            const dropdown = this.element.closest('.dropdown');
            if(dropdown && dropdown.tagName === 'DETAILS') {
                dropdown.removeAttribute('open');
            }
        } else {
            // Manteniamo il focus sull'input per far riapparire il dropdown vuoto o pronto per digitare
            this.inputTarget.focus()
        }
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

    clearInput() {
	if (this.hasInputTarget) {
	    this.inputTarget.value = ""
	    this.inputTarget.dispatchEvent(new Event("input"))
	}
    }
}
