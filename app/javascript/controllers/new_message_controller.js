import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-conversation"
export default class extends Controller {
  static targets = [ "templateSection", "textSection", "templateOutput" ]

  connect() {
    console.log('Hello from NewMessageController');
  }

  handleSelectChange(e){
    const value = e.target.value;
    console.log(this.templateSectionTarget)
    if (value === 'template'){

    } else {

    }
  }

  handleTextChange(e){
    console.log('text change', e);
  }
}
