import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    duration: { type: Number, default: 5000 },
    position: { type: String, default: "bottom-right" }
  }

  connect() {
    // Store bound handler so we can remove it later
    this.boundHandler = this.handleToastEvent.bind(this)
    document.addEventListener("toast:show", this.boundHandler)
  }

  disconnect() {
    document.removeEventListener("toast:show", this.boundHandler)
  }

  handleToastEvent(event) {
    const { message, type, duration } = event.detail
    this.show(message, type, duration)
  }

  show(message, type = "info", duration = this.durationValue) {
    const toast = this.createToast(message, type)
    this.containerTarget.appendChild(toast)

    requestAnimationFrame(() => {
      toast.classList.remove("translate-x-full", "opacity-0")
      toast.classList.add("translate-x-0", "opacity-100")
    })

    if (duration > 0) {
      setTimeout(() => this.dismiss(toast), duration)
    }
  }

  dismiss(toast) {
    toast.classList.remove("translate-x-0", "opacity-100")
    toast.classList.add("translate-x-full", "opacity-0")

    setTimeout(() => toast.remove(), 300)
  }

  dismissFromButton(event) {
    const toast = event.target.closest("[data-toast]")
    if (toast) this.dismiss(toast)
  }

  createToast(message, type) {
    const toast = document.createElement("div")
    toast.setAttribute("data-toast", "")
    toast.className = `
      flex items-center gap-3 p-4 rounded-lg shadow-lg border
      transform transition-all duration-300 ease-out
      translate-x-full opacity-0
      ${this.getTypeClasses(type)}
    `.trim().replace(/\s+/g, " ")

    toast.innerHTML = `
      ${this.getIcon(type)}
      <p class="flex-1 text-sm font-medium">${message}</p>
      <button type="button"
              class="flex-shrink-0 p-1 rounded hover:bg-black/10 dark:hover:bg-white/10 transition-colors"
              data-action="click->toast#dismissFromButton">
        <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
      </button>
    `

    return toast
  }

  getTypeClasses(type) {
    const classes = {
      success: "bg-green-50 dark:bg-green-900/30 border-green-200 dark:border-green-800 text-green-800 dark:text-green-200",
      error: "bg-red-50 dark:bg-red-900/30 border-red-200 dark:border-red-800 text-red-800 dark:text-red-200",
      warning: "bg-yellow-50 dark:bg-yellow-900/30 border-yellow-200 dark:border-yellow-800 text-yellow-800 dark:text-yellow-200",
      info: "bg-blue-50 dark:bg-blue-900/30 border-blue-200 dark:border-blue-800 text-blue-800 dark:text-blue-200"
    }
    return classes[type] || classes.info
  }

  getIcon(type) {
    const icons = {
      success: `
        <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      `,
      error: `
        <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      `,
      warning: `
        <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
      `,
      info: `
        <svg class="w-5 h-5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      `
    }
    return icons[type] || icons.info
  }
}

window.showToast = function(message, type = "info", duration = 5000) {
  document.dispatchEvent(new CustomEvent("toast:show", {
    detail: { message, type, duration }
  }))
}
