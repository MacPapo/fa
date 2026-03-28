// app/javascript/controllers/omnibox_controller.js
import { Controller } from "@hotwired/stimulus";
import { debounce } from "utils/debounce";

// Connects to data-controller="omnibox"
export default class extends Controller {
    static targets = ["input", "results", "skeleton"];

    connect() {
        this.performSearch = debounce(this.performSearch.bind(this), 300);
	if (document.documentElement.hasAttribute("data-turbo-preview")) return;

        this.boundPrepareForCache = this.prepareForCache.bind(this);
        document.addEventListener("turbo:before-cache", this.boundPrepareForCache);
    }

    disconnect() {
        document.removeEventListener("turbo:before-cache", this.boundPrepareForCache);
    }

    prepareForCache() {
        if (this.element.hasAttribute("open")) {
            this.element.close();
        }
        this.inputTarget.value = "";
        this.resetState();
    }

    search() {
        const query = this.inputTarget.value.trim();

        if (query.length >= 2) {
            this.showSkeleton();
            this.performSearch();
        } else {
            this.resetState();
        }
    }

    performSearch() {
        const urlString = this.inputTarget.dataset.url;
        if (!urlString) return;

        const url = new URL(urlString, window.location.origin);
        url.searchParams.set("query", this.inputTarget.value.trim());

        const frame = this.resultsTarget.querySelector("turbo-frame");
        if (frame) {
            frame.src = url.toString();
        }
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

    // --- GESTIONE STATI ---
    resetState() {
        this.hideSkeleton();
        const frame = this.resultsTarget.querySelector("turbo-frame");
        if (frame) {
            frame.removeAttribute("src");
            frame.innerHTML = `
              <div class="p-12 flex flex-col items-center justify-center text-center text-base-content/40 h-full mt-10">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-12 h-12 mb-4 opacity-20">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
                </svg>
                <p class="text-lg">Cosa stai cercando?</p>
                <p class="text-sm mt-1">Digita almeno 2 caratteri per iniziare la ricerca globale.</p>
              </div>`;
        }
    }

    resultsLoaded() {
        this.hideSkeleton();
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
