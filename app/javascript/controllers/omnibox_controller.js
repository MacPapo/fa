import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="omnibox"
export default class extends Controller {
    static targets = ["input", "form", "results", "skeleton", "item"];

    connect() {
	this.timeout = null;
	this.currentIndex = -1;
    }

    toggleShortcut(event) {
	if ((event.metaKey || event.ctrlKey) && event.key === "k") {
	    event.preventDefault();
	    if (this.element.hasAttribute("open")) {
		this.close();
	    } else {
		this.open();
	    }
	}
    }

    open() {
	this.element.showModal();
	setTimeout(() => {
	    this.inputTarget.focus();
	}, 10);
    }

    close() {
	this.element.close();
    }

    clearInput() {
	this.inputTarget.value = "";
	this.inputTarget.focus();
	this.resetState();
    }

    search() {
	clearTimeout(this.timeout);
	const query = this.inputTarget.value.trim();

	if (query.length >= 2) {
	    this.showSkeleton();
	    this.timeout = setTimeout(() => {
		this.formTarget.requestSubmit();
	    }, 300);
	} else {
	    this.resetState();
	}
    }

    // --- LA MAGIA DELLA TASTIERA ---
    navigate(event) {
	// Se non ci sono risultati, non fare nulla
	if (!this.hasItemTarget) return;

	if (event.key === "ArrowDown") {
	    event.preventDefault(); // Evita che il cursore si sposti nell'input testuale
	    // Incrementa l'indice, fermandosi all'ultimo elemento
	    this.currentIndex = Math.min(this.currentIndex + 1, this.itemTargets.length - 1);
	    this.updateSelection();
	} else if (event.key === "ArrowUp") {
	    event.preventDefault();
	    // Decrementa l'indice, fermandosi al primo elemento (0)
	    this.currentIndex = Math.max(this.currentIndex - 1, 0);
	    this.updateSelection();
	} else if (event.key === "Enter") {
	    // Se abbiamo selezionato qualcosa con le frecce, premiamo Invio per aprirlo
	    if (this.currentIndex >= 0) {
		event.preventDefault(); // Evita il submit standard del form Turbo
		
		const selectedItem = this.itemTargets[this.currentIndex];
		// Troviamo il link effettivo dentro l'elemento selezionato
		const link = selectedItem.tagName === "A" ? selectedItem : selectedItem.querySelector("a");
		
		if (link) {
		    link.click(); // Clicca il link programmaticamente
		    this.close(); // Chiudi la modale
		}
	    }
	}
    }

    updateSelection() {
	this.itemTargets.forEach((item, index) => {
	    if (index === this.currentIndex) {
		// Stile elemento ATTIVO
		item.classList.add("bg-base-200", "border-primary");
		item.classList.remove("border-transparent");
		
		// Questo è il trucco da pro: fa scorrere il div automaticamente se l'elemento è fuori vista!
		item.scrollIntoView({ block: "nearest" });
	    } else {
		// Stile elemento INATTIVO
		item.classList.remove("bg-base-200", "border-primary");
		item.classList.add("border-transparent");
	    }
	});
    }

    // --- GESTIONE STATI ---
    resetState() {
	this.currentIndex = -1;
	this.hideSkeleton();
	const frame = this.resultsTarget.querySelector("turbo-frame");
	if (frame) {
	    frame.innerHTML = `<div class="p-8 text-center text-base-content/50">Inizia a digitare per cercare...</div>`;
	}
    }

    // Questo viene chiamato da Turbo quando i risultati sono stati caricati
    resultsLoaded() {
	this.hideSkeleton();
	this.currentIndex = -1; // Resettiamo la selezione quando arrivano nuovi risultati
    }

    showSkeleton() {
	this.skeletonTarget.classList.remove("hidden");
	this.resultsTarget.classList.add("hidden");
    }

    hideSkeleton() {
	this.skeletonTarget.classList.add("hidden");
	this.resultsTarget.classList.remove("hidden");
    }
}
