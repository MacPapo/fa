import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    connect() {
	if (document.documentElement.hasAttribute("data-turbo-preview")) return

	this.element.showModal()

	document.addEventListener(
	    "turbo:before-cache",
	    () => this.element.remove(),
	    { once: true }
	)
    }

    close() {
	this.element.close()
    }

    clickOutside(event) {
	if (event.target === this.element) this.close()
    }

}
