import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["taxIdType", "taxIdContainer"]

  connect() {
    this.toggleTaxId()
  }

  toggleTaxId() {
    if (!this.hasTaxIdContainerTarget) return

    const taxIdType = this.taxIdTypeTarget.value

    if (taxIdType === "no_document") {
      this.taxIdContainerTarget.classList.add("hidden")
    } else {
      this.taxIdContainerTarget.classList.remove("hidden")
    }
  }
}
