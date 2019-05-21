require File.expand_path('../helper', __FILE__)

class AppOptics::Services::OutputTestCase < AppOptics::Services::TestCase
  ENV['APPOPTICS_APP_URL'] = 'metrics.appoptics.com'
  def test_clear
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      clear: "normal"
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name has cleared at 1970-05-23 14:32:03 UTC

Link: https://metrics.appoptics.com/alerts/1/details/123
EOF
    assert_equal(expected, output.markdown)
  end

  def test_clear_auto
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      clear: "auto"
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name was automatically cleared at 1970-05-23 14:32:03 UTC

Link: https://metrics.appoptics.com/alerts/1/details/123
EOF
    assert_equal(expected, output.markdown)
  end

  def test_clear_manual
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      clear: "manual"
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name was manually cleared at 1970-05-23 14:32:03 UTC

Link: https://metrics.appoptics.com/alerts/1/details/123
EOF
    assert_equal(expected, output.markdown)
  end

  def test_clear_unknown
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      clear: "unsupported"
    }
    output = AppOptics::Services::Output.new(payload)
    # fall back to the 'normal' case
    expected = <<EOF
# Alert Some alert name has cleared at 1970-05-23 14:32:03 UTC

Link: https://metrics.appoptics.com/alerts/1/details/123
EOF
    assert_equal(expected, output.markdown)
  end

  # use decimals in threshold and value to test the formatting of decimal places
  def test_simple_alert
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      conditions: [{type: "above", threshold: 10.5, id: 1}],
      triggered_by_user_test: false,
      violations: {
        "foo.bar" => [{
          metric: "metric.name", value: 100.12345, recorded_at: 1389391083,
          condition_violated: 1
        }]
      }
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name has triggered!

Link: https://metrics.appoptics.com/alerts/1/details/123

Source `foo.bar`:
* metric `metric.name` was above threshold 10.5 with value 100.123 recorded at Fri, Jan 10 2014 at 21:58:03 UTC
EOF
    assert_equal(expected, output.markdown)
  end

  def test_alert_triggered_by_user
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      conditions: [{type: "above", threshold: 10.5, id: 1}],
      triggered_by_user_test: true,
      violations: {
        "foo.bar" => [{
          metric: "metric.name", value: 100.12345, recorded_at: 1389391083,
          condition_violated: 1
        }]
      },
      auth: {
        email: "account@email.com"
      }
    }
    output = AppOptics::Services::Output.new(payload)
    assert include_test_alert_message?(output.markdown)
  end

  def test_complex_alert
    payload = {
      user_id: 1,
      alert: {id: 123, name: "Some alert name", version: 2},
      settings: {},
      service_type: "campfire",
      event_type: "alert",
      trigger_time: 12321123,
      triggered_by_user_test: false,
      conditions: [
        {type: "above", threshold: 10, id: 1},
        {type: "below", threshold: 100, id: 2},
        {type: "absent", threshold: nil, duration:600, id:3}
      ],
      violations: {
        "foo.bar" => [{
          metric: "metric.name", value: 100, recorded_at: 1389391083,
          condition_violated: 1
        }],
        "baz.lol" => [
          {metric: "something.else", value: 250, recorded_at: 1389391083,
          condition_violated: 1},
          {metric: "another.metric", value: 10, recorded_at: 1389391083,
          condition_violated: 2},
          {metric: "i.am.absent", value: 321, recorded_at: 1389391083,
          condition_violated: 3}
        ]
      }
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name has triggered!

Link: https://metrics.appoptics.com/alerts/1/details/123

Source `foo.bar`:
* metric `metric.name` was above threshold 10 with value 100 recorded at Fri, Jan 10 2014 at 21:58:03 UTC

Source `baz.lol`:
* metric `something.else` was above threshold 10 with value 250 recorded at Fri, Jan 10 2014 at 21:58:03 UTC
* metric `another.metric` was below threshold 100 with value 10 recorded at Fri, Jan 10 2014 at 21:58:03 UTC
* metric `i.am.absent` was absent for 600 seconds recorded at Fri, Jan 10 2014 at 21:58:03 UTC
EOF
    assert_equal(expected, output.markdown)
  end

  def test_bad_payload
    assert_raise RuntimeError do
      output = AppOptics::Services::Output.new({})
    end

    assert_raise NoMethodError do
      output = AppOptics::Services::Output.new({:conditions => "", :violations => ""})
    end
  end

  def test_lax_spacing_enabled

    markdown = <<EOF
# Alert Some alert name has triggered!

Source `foo.bar`:
* metric `metric.name` was above threshold 10 with value 100 recorded at Fri, Jan 10 2014 at 21:58:03 UTC
EOF
    expected = <<EOF
<h1>Alert Some alert name has triggered!</h1>

<p>Source <code>foo.bar</code>:</p>

<ul>
<li>metric <code>metric.name</code> was above threshold 10 with value 100 recorded at Fri, Jan 10 2014 at 21:58:03 UTC</li>
</ul>
EOF

    assert_equal(expected, AppOptics::Services::Output.renderer.render(markdown))
  end

  def test_windowed_alert
    payload = {
        user_id: 1,
        alert: {id: 123, name: "Some alert name", version: 2},
        settings: {},
        service_type: "campfire",
        event_type: "alert",
        trigger_time: 12321123,
        triggered_by_user_test: false,
        conditions: [{type: "above", threshold: 10, id: 1}],
        violations: {
            "foo.bar" => [{
                              metric: "metric.name", value: 100, recorded_at: 1389391083,
                              condition_violated: 1, count: 10, begin: 1389390903, end: 1389390993
                          }]
        }
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name has triggered!

Link: https://metrics.appoptics.com/alerts/1/details/123

Source `foo.bar`:
* metric `metric.name` was above threshold 10 over 90 seconds with value 100 recorded at Fri, Jan 10 2014 at 21:56:33 UTC
EOF
    assert_equal(expected, output.markdown)
  end

  def test_runbook_url
    payload = {
        user_id: 1,
        alert: {id: 123, name: "Some alert name", version: 2, runbook_url: "http://example.com/"},
        settings: {},
        service_type: "campfire",
        event_type: "alert",
        trigger_time: 12321123,
        triggered_by_user_test: false,
        conditions: [{type: "above", threshold: 10, id: 1}],
        violations: {
            "foo.bar" => [{
                              metric: "metric.name", value: 100, recorded_at: 1389391083,
                              condition_violated: 1
                          }]
        }
    }
    output = AppOptics::Services::Output.new(payload)
    expected = <<EOF
# Alert Some alert name has triggered!

Link: https://metrics.appoptics.com/alerts/1/details/123

Source `foo.bar`:
* metric `metric.name` was above threshold 10 with value 100 recorded at Fri, Jan 10 2014 at 21:58:03 UTC

Runbook: http://example.com/
EOF
    assert_equal(expected, output.markdown)
  end

  # Preserve underscores in (at least) alert name when rendering html
  def test_preserve_underscores_in_html
    payload = {
        alert: {id: 123, name: "Some_alert_name", version: 2, runbook_url: "http://example.com/"},
        settings: {},
        service_type: "campfire",
        event_type: "alert",
        trigger_time: 12321123,
        conditions: [{type: "above", threshold: 10, id: 1}],
        violations: {
            "foo.bar" => [{
                              metric: "metric.name", value: 100, recorded_at: 1389391083,
                              condition_violated: 1
                          }]
        }
    }
    output = AppOptics::Services::Output.new(payload)
    # Trying to avoid the <em> here
    assert_no_match(/Alert Some<em>alert<\/em>name/, output.generate_html)
    # In favor of underscores
    assert_match("Alert Some_alert_name", output.generate_html)
  end

  def test_violations_message
    payload = AppOptics::Services::Helpers::AlertHelpers.sample_new_alert_payload
    output = AppOptics::Services::Output.new(payload)

    assert_match('metric `metric.name` from `foo.bar`', output.sms_message)
  end

  def test_valid_sms
    payload = AppOptics::Services::Helpers::AlertHelpers.sample_new_alert_payload
    output = AppOptics::Services::Output.new(payload)

    assert_equal(true, output.valid_sms?)
  end

  def test_invalid_sms
    payload = AppOptics::Services::Helpers::AlertHelpers.sample_new_alert_payload
    payload['violations']['foo.bar'][0]['metric'] = SecureRandom.urlsafe_base64(160)[0..159]
    output = AppOptics::Services::Output.new(payload)

    assert_equal(false, output.valid_sms?)
  end

  def test_sms_message
    payload = AppOptics::Services::Helpers::AlertHelpers.sample_new_alert_payload
    output = AppOptics::Services::Output.new(payload)

    assert_equal(true, output.sms_message.length <= 140)
  end

  def test_truncated_sms_message
    payload = AppOptics::Services::Helpers::AlertHelpers.sample_new_alert_payload
    payload['violations']['foo.bar'][0]['metric'] = SecureRandom.urlsafe_base64(160)[0..159]
    output = AppOptics::Services::Output.new(payload)

    assert_equal(140, output.sms_message.length)
    assert_equal(true, output.sms_message.end_with?('...'))
  end
end # class
