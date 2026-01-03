import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "taxIdContainer", "taxIdInput", "usersContainer", "userTemplate"]

  connect() {
    this.toggle()
    this.userIndex = 1
  }

  toggle() {
    const isFormal = this.typeSelectTarget.value === "formal"
    
    if (isFormal) {
      this.taxIdContainerTarget.classList.remove("hidden")
    } else {
      this.taxIdContainerTarget.classList.add("hidden")
      this.taxIdInputTarget.value = ""
    }
  }

  addUser(event) {
    event.preventDefault()
    
    const template = this.userTemplateTarget.content.cloneNode(true)
    const userCard = template.querySelector("[data-user-card]")

    const userNumber = this.usersContainerTarget.querySelectorAll("[data-user-card]").length + 1
    const headerSpan = userCard.querySelector("[data-user-number]")
    if (headerSpan) {
      headerSpan.textContent = `Usuario #${userNumber}`
    }
    
    this.usersContainerTarget.appendChild(template)
    this.userIndex++
  }

  removeUser(event) {
    event.preventDefault()
    
    const userCard = event.target.closest("[data-user-card]")
    if (userCard) {
      userCard.remove()
      this.renumberUsers()
    }
  }

  renumberUsers() {
    const userCards = this.usersContainerTarget.querySelectorAll("[data-user-card]")
    userCards.forEach((card, index) => {
      const headerSpan = card.querySelector("[data-user-number]")
      if (headerSpan) {
        headerSpan.textContent = `Usuario #${index + 2}`
      }
    })
  }
}
