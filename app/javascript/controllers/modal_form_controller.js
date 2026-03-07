import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal-closer"
export default class extends Controller {
	handleSuccess(event) {
		if (event.detail.success) {
			this.element.closest("dialog").close()

			this.element.reset()

			const modalId = this.element.querySelector('[name="modal_id"]')?.value
			window.dispatchEvent(new CustomEvent("modal:success", { detail: { modalId: modalId } }))
		}
	}
}
