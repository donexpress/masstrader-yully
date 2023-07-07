import { Controller } from "@hotwired/stimulus";

function messagePreview(template, ...args) {
  return `
  Hai ${args[0]},

  Saya ialah penghantar ${args[1]} (${args[3]}) yang anda beli. Kami sedang menyediakan pesanan anda dengan Hadiah Surprise: ${args[2]}

  Sila balas *“Confirm”* untuk redeem hadiah surprise. Sila beritahu hari mana yang available untuk terima barang.

  Hubungilah kami
  WhatsApp: +60 196812677`;
}

// Connects to data-controller="new-conversation"
export default class extends Controller {
  static targets = [
    "select",
    "templateSection",
    "textSection",
    "templateOutput",
    "preview",
  ];

  connect() {
    console.log("Hello from NewMessageController");
    this.toggleSections(this.selectTarget.value);
    this.fillPreview();
  }

  fillPreview() {
    const preview = this.previewTarget;
    const clientName = document.getElementById("message_template_params[0]").value;
    const product = document.getElementById("message_template_params[1]").value;
    const specialGift = document.getElementById("message_template_params[2]").value;
    const referenceId = document.getElementById("message_template_params[3]").value;
    
    const messageType = document.getElementById("message_message_type").value;
    preview.value = messagePreview(
      messageType,
      clientName || "{clientName}",
      product || "{product}",
      specialGift || "{specialGift}",
      referenceId || "{referenceId}"
    );
    console.log(messageType);
  }

  toggleSections(value) {
    if (value === "template 1 (español)" || value === "template") {
      this.templateSectionTarget.hidden = false;
      this.textSectionTarget.hidden = true;
      this.fillPreview();
    } else {
      this.templateSectionTarget.hidden = true;
      this.textSectionTarget.hidden = false;
    }
  }

  handleSelectChange(e) {
    const value = e.target.value;
    this.toggleSections(value);
  }

  handleInputChange() {
    this.fillPreview();
  }

  disableButton() {
    alert("hello");
  }
}
