# Caltrain status as a JSON feed

Caltrain published status from Twitter on their website.
It would be much more useful as a JSON. Let's fix that.

We'll set this up with Functions Framework for Ruby.
https://github.com/GoogleCloudPlatform/functions-framework-ruby

## Local development

Install the bundle, and start the framework.
```
bundle install
bundle exec functions-framework-ruby --target status
```

In a separate shell, send requests to this function using curl.
```
curl http://localhost:8080
```

We should go to [the source](https://developer.twitter.com/en/docs/tutorials/step-by-step-guide-to-making-your-first-request-to-the-twitter-api-v2).

With the approach, we'll need to [use secrets](https://cloud.google.com/functions/docs/configuring/secrets#console) and use the
[Secret Manager client libraries](https://cloud.google.com/secret-manager/docs/reference/libraries#client-libraries-install-ruby).
