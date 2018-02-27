AppOptics Services
================

[![Build Status](https://secure.travis-ci.org/appoptics/appoptics-services.png)](http://travis-ci.org/appoptics/appoptics-services)

Service hooks for [AppOptics](https://my.appoptics.com).

Making a Release
----------------

To make a release of this project, follow these steps:

1. Merge all changes to `master` and ensure you are on the latest
   `master` branch.
1. Run `bundle exec rake version:bump:patch` (or minor/major depending
   on size of change).
1. Run `bundle exec rake gemspec:release`
1. Run `bundle exec rake git:release`

How the newest version is tagged and can be pulled from git using the
new version tag.

Service Lifecycle
-----------------

1. When a request to create a service is received by the API, the
   API calls the method `receive_validate` for the appropriate
   service class.
1. The service `receive_validate` method should validate the settings
   parameters. This method should return false with a set of invalid
   parameters if the settings are not correct for the service type.
1. Later, when a metric measurement is posted to the API that exceeds a
   configured alert threshold, the API records the exception.
1. A background job checks every minute for any alerts that have been
   triggered.
1. If any alerts have been triggered, the background job generates a
   POST to
   `https://<services-server>/services/<service_name>/alert.json` with
   the post data:
   - `params[:settings]`: the options the user specified in the Service configuration
   - `params[:payload]`: the event data for the triggered alert
1. A [sinatra][] app [lib/appoptics_services/app.rb][] decodes the request
   and dispatches it to a registered service if it exists

Writing a Service
-----------------

All services are found in the [services/][] directory. They must have a method
named `receive_alert` that is called when an alert is matched.

The settings are available as a `Hash` in the instance method `settings` and
the event payload is available as a `Hash` in the instance method `payload`.

Tests should accompany all services and are located in the [test/][]
directory.

Payload for a Triggered Alert
-----------------------------

A sample payload is available at
[lib/appoptics-services/helpers/alert_helpers.rb] and listed below:

```
"payload" : {
  "alert" : {
    "name" : "Alert name or nil",
    "id" : 12345,
  },
  "metric" : {
     "name" : "Name of the metric that tripped alert",
     "type" : "gauge" or "counter",
  },
  "measurements" : [{
     "value" : 4.5 (value that caused exception),
     "source" : "r3.acme.com" (source that caused exception
                               or "unassigned")
  }]
}
```

Payload for a Cleared Alert
---------------------------

```
"payload": {
   "alert":{
      "id":6268092,
      "name":"a.test.name",
      "runbook_url":"",
      "version":2
   },
   "account":"youremail@yourdomain.com",
   "trigger_time":1457040045,
   "clear":"normal"
   }
}
```


Sample Service
--------------

Here's a simple service that posts the measurement value(s) that
triggered the alert.

```ruby
class Service::Sample < Service
  def receive_validate(errors = {})
    if settings[:name].to_s.empty?
      errors[:name] = "Is required"
      return false
    else
      return true
    end
  end

  def receive_alert
    http_post 'https://sample-service.com/post.json' do |req|
      req.body = {
        settings[:name] => payload[:measurements]
      }
    end
  end
end
```

Contributing
------------

Once you've made your great commits:

1. [Fork][fk] `appoptics_services`
2. Create a topic branch — `git checkout -b my_branch`
3. Commit the changes without changing the Rakefile or other files unrelated to your enhancement.
4. Push to your branch — `git push origin my_branch`
5. Create a Pull Request or an [Issue][is] with a link to your branch
6. That's it!


Credits
-------

This project is heavily influenced in spirit and code by
[papertrail-services][] and [github-services][].
We love what GitHub has done for all of us and what they have demonstrated
can be accomplished with community involvement.

We thank them for everything they've done for all of us.

[lib/appoptics_services/app.rb]: https://github.com/appoptics/appoptics-services/blob/master/lib/appoptics_services/app.rb
[services/]: https://github.com/appoptics/appoptics-services/tree/master/services
[test/]: https://github.com/appoptics/appoptics-services/tree/master/test
[github-services]: https://github.com/github/github-services/
[papertrail-services]: https://github.com/papertrail/papertrail-services/
[sinatra]: http://www.sinatrarb.com/
[fk]: http://help.github.com/forking/
[is]: https://github.com/appoptics/appoptics_services/issues/
[AppOptics]: http://appoptics.com/
