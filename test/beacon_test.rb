require File.expand_path('../helper', __FILE__)

module AppOptics::Services
  class BeaconTest < AppOptics::Services::TestCase
    def setup
      @stubs = Faraday::Adapter::Test::Stubs.new
      @endpoint = '/alerts'
      @settings = {
        api_key: 'ABC1234',
        description: 'Alerts related to my favorite service'
      }
    end

    def test_empty_settings
      settings = {}
      svc = service(:alert, settings, payload={})
      errors = {}
      ret = svc.receive_validate(errors)
      assert !ret, 'should fail validation'
      assert_equal('is required', errors[:api_key])
      assert_equal('is required', errors[:description])
    end

    def test_settings_missing
      @settings.keys.each do |k|
        tmp = @settings.dup
        tmp.delete(k)
        svc = service(:alert, tmp, {})
        errors = {}
        ret = svc.receive_validate(errors)
        assert !ret, 'should fail validation'
        assert_equal('is required', errors[k])
      end
    end

    def test_valid_settings
      svc = service(:alert, @settings, {})
      errors = {}
      ret = svc.receive_validate(errors)
      assert ret, 'should pass validation'
      assert_equal(0, errors.length)
    end

    def test_api_key_header
      svc = service(:alert, @settings, tagged_alert_payload)
      @stubs.post '/alerts' do |env|
        assert_equal @settings[:api_key],
          env[:request_headers]['X-SWI-ALERT-API-KEY'],
          "Expected API key to be present in headers. #{env[:request_headers]}"
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_alert_definition_id
      svc = service(:alert, @settings, tagged_alert_payload)
      @stubs.post '/alerts' do |env|
        assert_equal "appoptics-#{tagged_alert_payload[:alert][:id]}", env[:body][:alert_definition_id]
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_alert_instance_origination_time
      svc = service(:alert, @settings, tagged_alert_payload)
      @stubs.post '/alerts' do |env|
        assert_equal tagged_alert_payload[:trigger_time], env[:body][:alert_instance_origination_time]
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_property_bag
      svc = service(:alert, @settings, tagged_alert_payload)
      @stubs.post '/alerts' do |env|
        bag = env[:body][:property_bag]
        assert_equal tagged_alert_payload[:alert][:id].to_s, bag[:alert_id]
        assert_equal tagged_alert_payload[:alert][:name], bag[:alert_name]
        assert_equal tagged_alert_payload[:alert][:description], bag[:alert_description]
        assert_equal tagged_alert_payload[:alert][:runbook_url], bag[:runbook_url]
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_alert_description_blank_uses_alert_name
      payload = tagged_alert_payload.dup
      payload[:alert][:description] = "" # AO allows this to be blank
      svc = service(:alert, @settings, payload)
      @stubs.post '/alerts' do |env|
        assert_equal payload[:alert][:name], env[:body][:property_bag][:alert_description]
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_receive_alert_clear
      # TBD
    end

    def service(*args)
      super AppOptics::Services::Service::Beacon, *args
    end
  end
end
