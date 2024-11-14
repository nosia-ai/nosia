import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-message-event-dispatcher"
export default class extends Controller {
  connect() {
    this.dispatch("new_message", {})
  }
}
