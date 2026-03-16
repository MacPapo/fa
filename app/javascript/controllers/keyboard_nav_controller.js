import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["item"];

    connect() {
        this.currentIndex = -1;
    }

    // Reset dell'indice se i risultati cambiano (es. caricamento Turbo Frame)
    itemTargetConnected() {
        this.currentIndex = -1;
    }

    navigate(event) {
        if (!this.hasItemTarget) return;

        if (event.key === "ArrowDown") {
            event.preventDefault();
            this.currentIndex = Math.min(this.currentIndex + 1, this.itemTargets.length - 1);
            this.updateSelection();
        } else if (event.key === "ArrowUp") {
            event.preventDefault();
            this.currentIndex = Math.max(this.currentIndex - 1, 0);
            this.updateSelection();
        } else if (event.key === "Enter") {
            // Preveniamo il submit del form di default
            event.preventDefault();

            if (this.currentIndex >= 0) {
                const selectedItem = this.itemTargets[this.currentIndex];
                const link = selectedItem.tagName === "A" ? selectedItem : selectedItem.querySelector("a");

                if (link) {
                    link.click();
                } else {
                    selectedItem.click(); // Fallback per elementi interattivi generici
                }
            }
        }
    }

    updateSelection() {
        this.itemTargets.forEach((item, index) => {
            if (index === this.currentIndex) {
                // Stile dell'elemento selezionato
                item.classList.add("bg-base-200", "border-primary");
                item.classList.remove("border-transparent");
                item.scrollIntoView({ block: "nearest", behavior: "smooth" });
            } else {
                // Stile di default
                item.classList.remove("bg-base-200", "border-primary");
                item.classList.add("border-transparent");
            }
        });
    }
}
