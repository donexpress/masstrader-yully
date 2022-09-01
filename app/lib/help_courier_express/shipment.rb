class HelpCourierExpress::Shipment

  def self.belongs_to?(tracking_number)
    @shipments ||= File.read('help-express.txt').split("\n")
    
    @shipments.include?(tracking_number)
  end

  def self.in_subset?(tracking_number)
    @sshipments ||= File.read('help-express-cf.txt').split("\n")
    
    @sshipments.include?(tracking_number)
  end
end
