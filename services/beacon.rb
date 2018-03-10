# encoding: utf-8

module AppOptics::Services
  class Service::Beacon < AppOptics::Services::Service
    def receive_validate(errors)
      [:api_key, :service_name, :description].each do |k|
        errors[k] = "is required" if settings[k].to_s.empty?
      end
      errors.none?
    end

    def receive_alert_clear
      receive_alert
    end

    def receive_alert
      # raise_config_error unless receive_validate({})

      beacon_payload = {}
      [:alert, :trigger_time, :conditions, :violations].each do |whitelisted|
        beacon_payload[whitelisted] = payload[whitelisted.to_s]
      end
      alert_name = payload['alert']['name']
      description = alert_name.blank? ? settings[:description] : alert_name
      if payload[:triggered_by_user_test]
        description = "[Test] " + description
      end

      body = {
        api_key: settings[:api_key],
        service_name: settings[:service_name],
        description: description,
        alert_payload: beacon_payload
      }

      body[:event_type] = payload[:clear] ? 'clear' : 'trigger'

      body[:alert_payload][:alert_url] = alert_link(payload['alert']['id'])
      unless payload['alert']['runbook_url'].blank?
        body[:alert_payload][:runbook_url] = payload['alert']['runbook_url']
      end
      unless payload['alert']['description'].blank?
        body[:alert_payload][:description] = payload['alert']['description']
      end

      url = "https://beacon-staging.solarwinds.com/incident"

      http_post(url, body, 'Content-Type' => 'application/json')
    end
  end
end
