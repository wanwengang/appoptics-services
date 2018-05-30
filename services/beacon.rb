# encoding: utf-8

module AppOptics::Services
  class Service::Beacon < AppOptics::Services::Service
    ENDPOINT = ENV['BEACON_API_ENDPOINT']

    def receive_validate(errors)
      [:api_key, :title, :description].each do |k|
        errors[k] = "is required" if settings[k].to_s.empty?
      end
      errors.none?
    end

    def receive_alert_clear
    end

    def receive_alert
      raise_config_error unless receive_validate({})

      body = {
        alert_definition_id: "appoptics-#{payload[:alert][:id]}",
        # alert_instance_id: "#{payload[:alert][:name]} + #{tags...}"
        alert_instance_id: payload[:incident_key],
        alert_instance_origination_time: payload[:trigger_time],
        description: settings[:title],
        url: alert_link(payload[:alert][:id])
      }
      body[:description] = "[TEST] #{body[:description]}" if payload[:triggered_by_user_test]

      # Property bag is a JSON blob that gets stored in Beacon along with the alert
      body[:property_bag] = {
        settings_description: settings[:description],
        alert_id: "#{payload[:alert][:id]}",
        alert_name: payload[:alert][:name],
        alert_description: payload[:alert][:description].blank? ? payload[:alert][:name] : payload[:alert][:description]
      }
      unless payload[:alert][:runbook_url].blank?
        body[:property_bag][:runbook_url] = payload[:alert][:runbook_url]
      end

      headers = {
        'Content-Type' => 'application/json',
        'X-SWI-ALERT-API-KEY' => settings[:api_key]
      }
      http_post(ENDPOINT, body, headers)
    end
  end
end
