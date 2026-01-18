import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "eyeIcon", "eyeOffIcon"]

  toggle() {
    const isPassword = this.inputTarget.type === "password"

    if (isPassword) {
      this.inputTarget.type = "text"
      this.eyeIconTarget.classList.add("hidden")
      this.eyeOffIconTarget.classList.remove("hidden")
    } else {
      this.inputTarget.type = "password"
      this.eyeIconTarget.classList.remove("hidden")
      this.eyeOffIconTarget.classList.add("hidden")
    }
  }
}
