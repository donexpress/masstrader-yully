import { Controller } from "@hotwired/stimulus"

function messagePreview(...args){
  return `Hola ${args[0]}: 

  Se nos ha confiado la entrega de ${args[1]} producto(s) que compra en línea. 

  Le agradeceríamos que respondiera "Confirmado" para que podamos enviar su producto de inmediato y enviarlo a la dirección ${args[2]}. 
  Los envíos son contra reembolso (COD) y solo se acepta pago en efectivo. Tenga efectivo por la cantidad de ${args[3]} listo para pagar cuando lo reciba. El tiempo de entrega es de 3-7 días. Después de confirmar el envío, si tiene alguna pregunta, puede usar la referencia: ${args[4]}, para comunicarse con service@mxwahaha.com. Este mensaje es solo para sus registros, si acepta la entrega, no utilizaremos esta ruta para el servicio al cliente.

  ¡Que tengas un buen día!
  `
}

// Connects to data-controller="new-conversation"
export default class extends Controller {
  static targets = [ "select", "templateSection", "textSection", "templateOutput", "preview" ]

  connect() {
    console.log('Hello from NewMessageController');
    this.toggleSections(this.selectTarget.value);
    this.fillPreview()
  }

  fillPreview(){
    const preview = this.previewTarget;
    const clientName = document.getElementById('message_template_params[0]').value;
    const product = document.getElementById('message_template_params[1]').value;
    const address = document.getElementById('message_template_params[2]').value;
    const amount = document.getElementById('message_template_params[3]').value;
    const referenceId = document.getElementById('message_template_params[4]').value;
    preview.value = messagePreview(clientName || '{clientName}', product || '{product}', address || '{address}', amount || '{amount}', referenceId || '{referenceId}');
  }

  toggleSections(value){
    if (value === 'template'){
      this.templateSectionTarget.hidden = false;
      this.textSectionTarget.hidden = true;
    } else {
      this.templateSectionTarget.hidden = true;
      this.textSectionTarget.hidden = false;
    }
  }

  handleSelectChange(e){
    const value = e.target.value;
    this.toggleSections(value);
  }

  handleInputChange(){
    this.fillPreview();
  }
}
