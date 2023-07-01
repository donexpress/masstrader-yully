import { Controller } from "@hotwired/stimulus";

function messagePreview(template, ...args) {
  return `
  Important: Reply "*confirm*" to Confirm *FREE Gift* and Your Order Shipment
    Dear ${args[0]},
    Here is the delivery center of your order ${args[3]} ${args[1]}, ${args[4]} at Zkvay. To confirm your order shipment and *FREE Gift* we offer: ${args[2]}, please reply to this message with the word "*confirm*".
    Once receiving your confirmation, we will ship your order within 12 hours. Estimated delivery time is 1-3 days.
    Feel free to contact us:
    WhatsApp: +60 196812677
    Email: service@daynel.com`;
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
    const amount = document.getElementById("message_template_params[4]").value;
    
    const messageType = document.getElementById("message_message_type").value;
    preview.value = messagePreview(
      messageType,
      clientName || "{clientName}",
      product || "{product}",
      specialGift || "{specialGift}",
      referenceId || "{referenceId}",
      amount || "{amount}",
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
