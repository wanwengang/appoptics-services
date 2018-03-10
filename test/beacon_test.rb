require File.expand_path('../helper', __FILE__)

module AppOptics::Services
  class BeaconTest < AppOptics::Services::TestCase
    def setup
      @stubs = Faraday::Adapter::Test::Stubs.new
      @endpoint = '/incident'
      @settings = {
        api_key: 'ABC1234',
        service_name: 'web',
        description: 'My web app'
      }
    end

    def test_empty_settings
      settings = {}
      svc = service(:alert, settings, payload={})
      errors = {}
      ret = svc.receive_validate(errors)
      assert !ret, 'should fail validation'
      assert_equal('is required', errors[:api_key])
      assert_equal('is required', errors[:service_name])
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

    def test_receive_alert
      svc = service(:alert, @settings, alert_payload)
      @stubs.post '/incident' do |env|
        assert env[:body][:api_key]
        [200, {}, '']
      end
      resp = svc.receive_alert
      assert_equal(200, resp.status)
    end

    def test_receive_alert_clear
      svc = service(:alert, @settings, alert_payload)
      # svc.receive_alert_clear
    end


    def service(*args)
      super AppOptics::Services::Service::Beacon, *args
    end
  end
end
