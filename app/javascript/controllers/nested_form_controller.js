import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["template", "list"]

    addFromEvent(event) {
        // Fallback: se l'evento non ha dati, fermati
        if (!event.detail || !event.detail.id) return

        const { id, name } = event.detail
        const uniqueKey = new Date().getTime()

        // Preleva il template HTML grezzo
        let content = this.templateTarget.innerHTML

        // Rimpiazza le stringhe segnaposto
        content = content.replace(/NEW_RECORD/g, uniqueKey)
        content = content.replace(/TEMPLATE_ID/g, id)
        content = content.replace(/TEMPLATE_NAME/g, name)

        // Inietta la nuova riga in fondo alla lista
        this.listTarget.insertAdjacentHTML('beforeend', content)
    }

    remove(event) {
        const row = event.target.closest('[data-nested-target="row"]')
        if (row) {
            row.style.display = 'none'
            const destroyInput = row.querySelector('[data-nested-target="destroy"]')
            if (destroyInput) destroyInput.value = '1'
        }
    }
}
