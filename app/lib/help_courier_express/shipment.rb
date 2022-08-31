class HelpCourierExpress::Shipment

  def self.belongs_to?(tracking_number)
    @shipments ||= File.read('help-express.txt').split("\n")
    
    @shipments.include?(tracking_number)
  end
end
