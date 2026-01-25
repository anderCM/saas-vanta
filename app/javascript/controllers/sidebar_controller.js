import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["collapsible", "expandIcon", "collapseIcon"]
  static classes = ["collapsed"]

  connect() {
    // Check localStorage for saved state (only on desktop)
    if (!this.isMobile()) {
      const isCollapsed = localStorage.getItem("sidebarCollapsed") === "true"
      if (isCollapsed) {
        this.collapse()
      }
    }

    // Listen for window resize to handle responsive changes
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  handleResize() {
    // Close mobile sidebar when resizing to desktop
    if (!this.isMobile() && this.element.classList.contains("sidebar-mobile-open")) {
      this.closeMobile()
    }
  }

  isMobile() {
    return window.innerWidth <= 768
  }

  toggle() {
    // Don't allow toggle on mobile
    if (this.isMobile()) {
      return
    }

    if (this.element.classList.contains("sidebar-collapsed")) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  collapse() {
    this.element.classList.add("sidebar-collapsed")
    this.collapsibleTargets.forEach(el => el.classList.add("hidden"))
    this.expandIconTargets.forEach(el => el.classList.remove("hidden"))
    this.collapseIconTargets.forEach(el => el.classList.add("hidden"))
    localStorage.setItem("sidebarCollapsed", "true")

    // Dispatch event for other components that might need to know
    this.dispatch("collapsed")
  }

  expand() {
    this.element.classList.remove("sidebar-collapsed")
    this.collapsibleTargets.forEach(el => el.classList.remove("hidden"))
    this.expandIconTargets.forEach(el => el.classList.add("hidden"))
    this.collapseIconTargets.forEach(el => el.classList.remove("hidden"))
    localStorage.setItem("sidebarCollapsed", "false")

    // Dispatch event for other components that might need to know
    this.dispatch("expanded")
  }

  // Mobile-specific methods
  openMobile() {
    this.element.classList.add("sidebar-mobile-open")
    document.body.style.overflow = "hidden" // Prevent body scroll
    this.dispatch("mobileOpen")
  }

  closeMobile() {
    this.element.classList.remove("sidebar-mobile-open")
    document.body.style.overflow = "" // Restore body scroll
    this.dispatch("mobileClosed")
  }
}
