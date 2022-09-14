import { Controller } from "@hotwired/stimulus"

function messagePreview(...args){
  return `Hola ${args[0]}: 

  Estamos encargados del despacho del producto ${args[1]} que compraste en línea. 

  Te agradeceríamos responder "CONFIRMADO" para que inmediatamente despachemos tu producto el cuál será entregado en la dirección ${args[2]}. 
  El despacho es un cobro contra entrega (COD) y sólo se admiten pagos en efectivo. Por favor, ten listo el monto ${args[3]} en efectivo para pagar al recibirlo. Una vez confirmado el despacho puedes buscar tu pedido con el siguiente número en Shopify: ${args[4]}, dónde podrás también obtener el número de seguimiento.

  El tiempo de entrega es de 3-7 días naturales. 

  Te deseamos un feliz día!

  PD: Recuerda que puedes contactar directamente al vendedor y disfrutar de tu garantía de por vida.
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
