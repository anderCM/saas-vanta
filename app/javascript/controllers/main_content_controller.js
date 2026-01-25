import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "overlay"]

  connect() {
    // Check initial state from localStorage (only on desktop)
    if (!this.isMobile()) {
      const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
      if (isCollapsed) {
        this.collapse()
      }
    }
  }

  isMobile() {
    return window.innerWidth <= 768
  }

  collapse() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("sidebar-is-collapsed")
    }
  }

  expand() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("sidebar-is-collapsed")
    }
  }

  // Mobile sidebar methods
  openSidebar() {
    const sidebar = document.querySelector("[data-controller='sidebar']")
    if (sidebar) {
      const sidebarController = this.application.getControllerForElementAndIdentifier(sidebar, "sidebar")
      if (sidebarController) {
        sidebarController.openMobile()
      }
    }
  }

  closeSidebar() {
    const sidebar = document.querySelector("[data-controller='sidebar']")
    if (sidebar) {
      const sidebarController = this.application.getControllerForElementAndIdentifier(sidebar, "sidebar")
      if (sidebarController) {
        sidebarController.closeMobile()
      }
    }
  }

  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("active")
    }
  }

  hideOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("active")
    }
  }
}
