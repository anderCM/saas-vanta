import consumer from "channels/consumer"

consumer.subscriptions.create("NotificationsChannel", {
  connected() {
    console.log("Connected to NotificationsChannel")
  },

  disconnected() {
    console.log("Disconnected from NotificationsChannel")
  },

  received(data) {
    console.log("Received notification:", data)

    document.dispatchEvent(new CustomEvent("toast:show", {
      detail: {
        message: data.message,
        type: data.type || "info",
        duration: data.duration || 5000
      }
    }))
  }
})

console.log("NotificationsChannel subscription created")
