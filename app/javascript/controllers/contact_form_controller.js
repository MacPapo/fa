import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="contact-form"
export default class extends Controller {
	static targets = ["personRadio", "companyRadio", "personFields", "companyFields"]

	connect() {
		this.toggle()
	}

	toggle() {
		if (this.personRadioTarget.checked) {
			this.personFieldsTarget.classList.remove("hidden")
			this.companyFieldsTarget.classList.add("hidden")
		} else {
			this.personFieldsTarget.classList.add("hidden")
			this.companyFieldsTarget.classList.remove("hidden")
		}
	}
}
