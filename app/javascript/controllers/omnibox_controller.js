import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="omnibox"
export default class extends Controller {
    static targets = ["input", "form", "dropdown"];

    connect() {
	this.timeout = null;
    }

    // Scorciatoia da tastiera ⌘+K per mettere a fuoco l'input
    focusShortcut(event) {
	if ((event.metaKey || event.ctrlKey) && event.key === "k") {
	    event.preventDefault();
	    this.inputTarget.focus();
	}
    }

    // Chiamato ad ogni lettera digitata
    search() {
	clearTimeout(this.timeout);
	const query = this.inputTarget.value.trim();

	if (query.length >= 2) {
	    this.open();

	    // Aspetta 300ms (Debounce) per non fare una query a ogni singola lettera
	    this.timeout = setTimeout(() => {
		// FONDAMENTALE: requestSubmit() permette a Turbo di intercettare il form.
		// Se usi submit(), Turbo impazzisce e ti fa il redirect alla pagina vuota.
		this.formTarget.requestSubmit();
	    }, 300);
	} else {
	    this.close();
	}
    }

    open() {
	this.dropdownTarget.classList.remove("hidden");
    }

    close() {
	// Un piccolo delay prima di chiudere, altrimenti se clicchi
	// su un risultato il menu sparisce prima che il link venga attivato!
	setTimeout(() => {
	    this.dropdownTarget.classList.add("hidden");
	}, 150);
    }
}
