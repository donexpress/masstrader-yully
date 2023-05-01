import { Controller } from "@hotwired/stimulus";

function messagePreview(template, ...args) {
  return `Dear customer ${args[0]}:

    Here is the delivery center of ${args[1]}, which you ordered online. We hope you are excited to get your order and the special gift we offer: Panasonic vacuum cleaner worth 99 MYR!
    To proceed with the delivery of your order, please reply to this message with the word "*yes*". After receiving your confirmation, our courier will deliver your package to the address you provided: ${args[2]}.
    Your order will be shipped within 24 hours and estimated delivery time is 1-3 days. Payment will be made upon delivery (COD), and the amount is ${args[3]}.

    Feel free to contact us: service@jayfy.com reference ${args[4]}.`;
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
    const clientName = document.getElementById(
      "message_template_params[0]"
    ).value;
    const product = document.getElementById("message_template_params[1]").value;
    const address = document.getElementById("message_template_params[2]").value;
    const amount = document.getElementById("message_template_params[3]").value;
    const referenceId = document.getElementById(
      "message_template_params[4]"
    ).value;
    const messageType = document.getElementById("message_message_type").value;
    preview.value = messagePreview(
      messageType,
      clientName || "{clientName}",
      product || "{product}",
      address || "{address}",
      amount || "{amount}",
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
