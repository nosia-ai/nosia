import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  connect() {
    this.#scrollToBottomSmooth()
  }

  scrollToBottom(event) {
    this.#scrollToBottomSmooth()
  }

  #scrollToBottomSmooth() {
    this.element.scroll({
      top: this.element.scrollHeight,
      behavior: "smooth"
    })
  }
}
