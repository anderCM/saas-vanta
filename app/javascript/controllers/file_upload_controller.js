import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "fileName", "icon"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    const dropzone = this.hasDropzoneTarget ? this.dropzoneTarget : this.element

    dropzone.addEventListener("dragover", (e) => this.handleDragOver(e))
    dropzone.addEventListener("dragleave", (e) => this.handleDragLeave(e))
    dropzone.addEventListener("drop", (e) => this.handleDrop(e))
  }

  handleDragOver(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.add("border-primary", "bg-primary/5")
    this.element.classList.remove("border-border")
  }

  handleDragLeave(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.remove("border-primary", "bg-primary/5")
    this.element.classList.add("border-border")
  }

  handleDrop(e) {
    e.preventDefault()
    e.stopPropagation()
    this.element.classList.remove("border-primary", "bg-primary/5")
    this.element.classList.add("border-border")

    const files = e.dataTransfer.files
    if (files.length > 0) {
      this.inputTarget.files = files
      this.updateFileName(files[0])
    }
  }

  updateFileName(arg = null) {
    let file = null

    if (arg instanceof Event) {
      file = arg.target.files?.[0]
    }

    else if (arg instanceof File) {
      file = arg
    }

    else if (this.inputTarget.files.length > 0) {
      file = this.inputTarget.files[0]
    }

    if (!file || !this.hasFileNameTarget) return

    const fileSize = this.formatFileSize(file.size)
    const isValidType = this.isValidFileType(file)

    if (isValidType) {
      this.fileNameTarget.innerHTML = `
      <div class="flex items-center justify-center gap-2 text-primary">
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <span class="font-medium">${file.name}</span>
        <span class="text-muted-foreground">(${fileSize})</span>
      </div>
    `
    } else {
      this.fileNameTarget.innerHTML = `
      <div class="flex items-center justify-center gap-2 text-destructive">
        <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <span class="font-medium">Formato no válido</span>
        <span class="text-muted-foreground">(usa .xlsx, .xls o .csv)</span>
      </div>
    `
      this.inputTarget.value = ""
    }
  }

  formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  isValidFileType(file) {
    const validTypes = [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // .xlsx
      'application/vnd.ms-excel', // .xls
      'text/csv' // .csv
    ]
    const validExtensions = ['.xlsx', '.xls', '.csv']

    const hasValidType = validTypes.includes(file.type)
    const hasValidExtension = validExtensions.some(ext =>
      file.name.toLowerCase().endsWith(ext)
    )

    return hasValidType || hasValidExtension
  }
}
