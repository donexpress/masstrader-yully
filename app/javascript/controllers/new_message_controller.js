import { Controller } from "@hotwired/stimulus"

function messagePreview(...args){
  return `Hola! Estamos encargados del despacho del producto ${args[0]} que compraste en línea. 

  Te agradeceríamos responder "CONFIRMADO" para que inmediatamente despachemos tu producto el cuál será entregado en la dirección ${args[1]}. El despacho es un cobro contra entrega (COD) y sólo se admiten pagos en efectivo. Por favor, ten listo el monto ${args[2]} en efectivo para pagar al recibirlo.

  Te enviaremos un número de seguimiento a tu correo o a través de este medio una vez que el envío sea despachado.

  El tiempo de entrega es 3-7 días naturales. 

  Te deseamos un feliz día! 😀

  PD: Te recordamos cordialmente que el vendedor ofrece una garantía de por vida, y te invitamos a contactarlo directamente en caso de cualquier eventualidad.`
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
    const product = document.getElementById('message_template_params[0]').value;
    const address = document.getElementById('message_template_params[1]').value;
    const amount = document.getElementById('message_template_params[2]').value;
    preview.value = messagePreview(product || '{product}', address || '{address}', amount || '{amount}');
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
