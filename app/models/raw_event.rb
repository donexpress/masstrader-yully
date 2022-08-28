class RawEvent < ApplicationRecord
  validates :data, presence: true

  def self.to_csv(opts = {})
    attributes = %w[date office tracking description location]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      raw_events = []
      all.find_each do |raw_event|
        raw_events << raw_event
      end

      if opts[:filter] == 'latest'
        reverse_raw_events = raw_events.reverse
        grouped_raw_events = reverse_raw_events.group_by do |raw_event|
          raw_event.data['tracking']
        end

        raw_events = grouped_raw_events.transform_values(&:first).values.flatten.reverse
      end

      inject_into_csv(csv, raw_events, attributes)
    end
  end

  def self.inject_into_csv(csv, raw_events, attributes)
    raw_events.each do |raw_event|
      csv << attributes.map do |attr|
        if attr == 'location'
          if RawEvent.override_contact_threshold?(raw_event.id)
            next 'Contact contacto@easy2go.cl'
          else
            next RawEvent.location_from_milestone(raw_event.data['description'])
          end
        end

        if attr == 'description'
          if RawEvent.override_contact_threshold?(raw_event.id) && raw_event.data['description'].upcase == 'DISPATCHED'
            next 'DELIVERY FAILED'
          else
            next RawEvent.map_milestone(raw_event.data[attr])
          end
        end

        if attr == 'date'
          if RawEvent.after_threshold?(raw_event.data[attr], raw_event.id)
            next RawEvent.swap_month_day(raw_event.data[attr])
          else
            next raw_event.data[attr]
          end
        end

        if raw_event.data[attr].downcase == 'e2go'
          'CL2'
        else
          raw_event.data[attr]
        end
      end
    end
  end

  def self.after_threshold?(ts_str, id)
    return false if id > 621

    threshold_dt = DateTime.parse("2022-05-25")
    DateTime.parse(ts_str).after? threshold_dt
  end

  def self.override_contact_threshold?(id)
    id >= 148124 && id <= 148742
  end

  def self.swap_month_day(ts_str)
    month = ts_str[5..6]
    day = ts_str[8..9]
    ts_str[0..4] + day + "-" + month + ts_str[10..]
  end

  def self.map_milestone(milestone)
    if milestone.upcase == 'LOADED'
      return 'PRE-ALERT LOADED'
    end

    if milestone.upcase == 'RECEIVED'
      return 'RECEIVED BY DISTRIBUTOR'
    end

    if milestone.upcase == 'ASSIGNED'
      return 'ASSIGNED LAST MILE DELIVERY'
    end

    if milestone.upcase == 'NOT AVAILABLE'
      return 'The package was not received by distributor (not available)'.upcase
    end

    if milestone.upcase == 'REFUSED'
      return 'The package cannot be delivered'.upcase
    end

    milestone
  end

  def self.location_from_milestone(milestone)
    case milestone
    when 'Entregado'
      'Domicilio del cliente'
    when 'Pago Exitoso', 'A la espera del pago de impuestos', 'Recepcionado'
      'Bodega easy2go'
    when 'No Hay Quien Reciba', 'Recepción Destino'
      'Sucursal última milla'
    when 'Dir Insuficiente', 'Rechazado'
      'Ubicación desconocida'
    when 'Despachado', 'Despacho Mayor', 'Despacho Menor'
      'En tránsito'
    when 'Bloqueados'
      'Ubicación desconocida'
    when 'Recepción Aeropuerto'
      'Aeropuerto'
    when 'PreAlerta'
      'Origen'
    else
      'Ubicación desconocida'
    end
  end

  # def self.location_from_milestone(milestone)
  #   case milestone.upcase
  #   when  'DELIVERED'
  #     'Recipient\'s address'.upcase
  #   when 'RECEIVED'
  #     'Destination Distribution Center'.upcase
  #   when 'RELEASED CUSTOMS'
  #     'Airport'.upcase
  #   when 'NOT AVAILABLE'
  #     'Origin or unknown'.upcase
  #   when 'DETAINED IN CUSTOMS'
  #     'Airport'.upcase
  #   when 'ASSIGNED'
  #     'Destination branch office'.upcase
  #   when 'LOADED'
  #     'Origin'.upcase
  #   when 'REFUSED'
  #     'Airport'.upcase
  #   when 'DISPATCHED'
  #     'Destination Distribution Center'.upcase
  #   else
  #     "Milestone: #{milestone} does not have location."
  #   end
  # end
end
