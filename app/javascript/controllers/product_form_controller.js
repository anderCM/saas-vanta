import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sourceType", "providerContainer"]

  connect() {
    this.toggleProvider()
  }

  toggleProvider() {
    if (!this.hasProviderContainerTarget) return

    const sourceType = this.sourceTypeTarget.value

    if (sourceType === "purchased") {
      this.providerContainerTarget.classList.remove("hidden")
    } else {
      this.providerContainerTarget.classList.add("hidden")
    }
  }
}
