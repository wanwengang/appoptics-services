require 'tilt'
require 'active_support'

module AppOptics
  module Services
    module Helpers
      module AlertHelpers
        def self.sample_alert_payload
          {
            :alert => {
              :id => 12345,
              :name => ""
            },
            :metric => {
              :name => "my_sample_alert",
              :type => "gauge"
            },
            :measurement => { :value => 2345.9, :source => "r3.acme.com" },
            :trigger_time => 1321311840
          }.with_indifferent_access
        end

        def self.sample_alert_payload_multiple_measurements
          {
            :alert => {
              :id => 12345
            },
            :metric => {
              :name => "my_sample_alert",
              :type => "gauge"
            },
            :measurements => [
              { :value => 2345.9, :source => "r3.acme.com" },
              { :value => 123,    :source => "r2.acme.com" }
            ],
            :trigger_time => 1321311840
          }.with_indifferent_access
        end

        #TODO rename when it's no longer "new"
        def self.sample_new_alert_payload
          ::HashWithIndifferentAccess.new({
            user_id: 1,
            incident_key: "foo",
            alert: {id: 123,
                    name: "Some alert name",
                    version: 2,
                    description: "Verbose alert explanation",
                    runbook_url: "http://runbooks.com/howtodoit"},
            auth: {email:"foo@example.com", annotations_token:"lol"},
            service_type: "campfire",
            event_type: "alert",
            triggered_by_user_test: false,
            trigger_time: 12321123,
            conditions: [{type: "above", threshold: 10, id: 1}],
            violations: {
              "foo.bar" => [{
                metric: "metric.name", value: 100, recorded_at: 1389391083,
                condition_violated: 1
              }]
            }
          })
        end

        def self.sample_tagged_alert_payload
          {
            account: "ops@example.com",
            alert: {
              description: "Test alert",
              id: 7505423,
              name: "my.test.alert",
              runbook_url: "http://github.com",
              version: 2
            },
            conditions: [
              {id: 45174468, summary_function: "sum", threshold: 42, type: "above"}
            ],
            incident_key: "librato-7505423-5291457",
            trigger_time: 1527622213,
            triggered_by_user_test: false,
            violations: {
              "apiname=yourapi,awsaccount=dev" => [
                {"condition_violated"=>45174468, "metric"=>"AWS.ApiGateway.Count", "recorded_at"=>1527621420, "value"=>43}
              ],
              "apiname=yourapi,awsaccount=dev,method=post,resource=/ingest,stage=dev" => [
                {"condition_violated"=>45174468, "metric"=>"AWS.ApiGateway.Count", "recorded_at"=>1527622080, "value"=>43}
              ]
            }
          }.with_indifferent_access
        end

        def get_measurements(body)
          measurements = body['measurements'] || []
          measurements << body['measurement']
          measurements.compact
        end

        def erb(template, target_binding)
          ERB.new(template, nil, '-').result(target_binding)
        end

        def h(text)
          ERB::Util.h(text)
        end

        def test_alert_message()
          "This is a test alert notification, no action is required."
        end

        def unindent(string)
          indentation = string[/\A\s*/]
          string.strip.gsub(/^#{indentation}/, "") + "\n"
        end

        def pluralize(count, singular, plural = nil)
          "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
        end

        def metric_link(type, name)
          "https://#{ENV['APPOPTICS_APP_URL']}/metrics/#{name}"
        end

        def alert_link(id)
          "https://#{ENV['APPOPTICS_APP_URL']}/alerts/#{id}"
        end

        # TODO: fix for specific alert id?
        def payload_link(payload)
          if payload[:alert][:version] == 2
            "https://#{ENV['APPOPTICS_APP_URL']}/metrics/"
          else
            metric_link(payload[:metric][:type], payload[:metric][:name])
          end
        end
      end
    end
  end
end
