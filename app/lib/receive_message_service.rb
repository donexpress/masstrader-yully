# frozen_string_literal: true

# Processes webhook incoming messages from the WhatsApp API
class ReceiveMessageService
  WA_OUTGOING_PHONE_NUMBER_ID = '108212608656928'
  # {
  #     "object":"whatsapp_business_account",
  #     "entry":[
  #        {
  #           "id":"109959988481020",
  #           "changes":[
  #              {
  #                 "value":{
  #                    "messaging_product":"whatsapp",
  #                    "metadata":{
  #                       "display_phone_number":"56959261264",
  #                       "phone_number_id":"108212608656928"
  #                    },
  #                    "contacts":[
  #                       {
  #                          "profile":{
  #                             "name":"Chile WOM"
  #                          },
  #                          "wa_id":"56920799906"
  #                       }
  #                    ],
  #                    "messages":[
  #                       {
  #                          "from":"56920799906",
  #                          "id":"wamid.HBgLNTY5MjA3OTk5MDYVAgASGCBFMDFDNzY1MUQ3RkQyNUNEQ0FBMzY0NEZFMEI2NTk5QQA=",
  #                          "timestamp":"1661104813",
  #                          "text":{
  #                             "body":"Love me love me"
  #                          },
  #                          "type":"text"
  #                       }
  #                    ]
  #                 },
  #                 "field":"messages"
  #              }
  #           ]
  #        }
  #     ]
  #  }

  def initialize(payload)
    @messages = []
    @payload = payload
  end

  def process
    incoming_messages = @payload['entry']['changes']['value']['messages']
    incoming_messages.map do |incoming_message|
      message = Message.new(outgoing: false)
      message.message = incoming_message['text']['body']
      message.receiver_phone_number = incoming_message['from']
    end
  end
end
