module PhoneNumber
  def sanitize_phone_number(phone_number)
    phone_number.gsub(/\D+/, '')
  end

  def localize_phone_number(phone_number)
    if phone_number.start_with?('52') && phone_number.length == 12
      phone_number.insert(2, '1')
    else
      phone_number
    end
  end

  def sanitize_and_localize_phone_number(phone_number)
    localize_phone_number(sanitize_phone_number(phone_number))
  end
end
