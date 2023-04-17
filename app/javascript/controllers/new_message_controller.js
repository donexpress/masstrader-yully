import { Controller } from "@hotwired/stimulus"

function messagePreview(template, ...args) {
  if (template === 'template 1 (español)') {
    return `Hola ${args[0]}: 

  Se nos ha confiado la entrega de ${args[1]} producto(s) que compra en línea. 

  Le agradeceríamos que respondiera "Confirmado" para que podamos enviar su producto de inmediato y enviarlo a la dirección ${args[2]}. 
  Los envíos son contra reembolso (COD) y solo se acepta pago en efectivo. Tenga efectivo por la cantidad de ${args[3]} listo para pagar cuando lo reciba. El tiempo de entrega es de 3-7 días. Después de confirmar el envío, si tiene alguna pregunta, puede usar la referencia: ${args[4]}, para comunicarse con service@mxwahaha.com. Este mensaje es solo para sus registros, si acepta la entrega, no utilizaremos esta ruta para el servicio al cliente.

  ¡Que tengas un buen día!
  `
  } else {
    return `Dear customer ${args[0]}:
    We have been entrusted with the delivery of ${args[1]}, which you have purchased online.
    We would be grateful if you could answer "Confirmed" so that we can send your product immediately to the address ${args[2]}. If you do not wish to receive the product we still need you to reply "Canceled". Shipments are COD and only cash payment is accepted. Please have cash ready in the amount of ${args[3]} to pay when you receive it. Delivery time is 3-7 days.
    After Confirm shipment, if you have any questions, you can use reference ${args[4]}. This message is for your record only, if you accept delivery, we will not use this route for customer service.`
  }
}

// Connects to data-controller="new-conversation"
export default class extends Controller {
  static targets = ["select", "templateSection", "textSection", "templateOutput", "preview"]

  connect() {
    console.log('Hello from NewMessageController');
    this.toggleSections(this.selectTarget.value);
    this.fillPreview()
  }

  fillPreview() {
    const preview = this.previewTarget;
    const clientName = document.getElementById('message_template_params[0]').value;
    const product = document.getElementById('message_template_params[1]').value;
    const address = document.getElementById('message_template_params[2]').value;
    const amount = document.getElementById('message_template_params[3]').value;
    const referenceId = document.getElementById('message_template_params[4]').value;
    const messageType = document.getElementById('message_message_type').value;
    preview.value = messagePreview(messageType, clientName || '{clientName}', product || '{product}', address || '{address}', amount || '{amount}', referenceId || '{referenceId}');
    console.log(messageType)

  }

  toggleSections(value) {
    if (value === 'template 1 (español)' || value === 'template 2 (english)') {
      this.templateSectionTarget.hidden = false;
      this.textSectionTarget.hidden = true;
      this.fillPreview()
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
}
