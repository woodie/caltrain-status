# Caltrain status as a JSON feed

Caltrain published status from Twitter on [their website](https://www.caltrain.com/alerts?active_tab=service_alerts_tab).
This project extracts a status JSON [here](https://us-central1-next-caltrain-pwa.cloudfunctions.net/status)
that is used by the [Next Caltrain](https://github.com/woodie/next-caltrain-pwa) app.
```
+-----------+
| <marquee> | <- "Train 514 SB is running 10 minutes
|           |     late approaching Redwood City."
| Train 514 |
| selected  |
+-----------+
```
This project uses [Functions Framework for Ruby](https://github.com/GoogleCloudPlatform/functions-framework-ruby)
and accesses a Bearer Token from [secrets](https://cloud.google.com/functions/docs/configuring/secrets#console)
as an environment variable.
See [Writing Functions documentation](https://github.com/GoogleCloudPlatform/functions-framework-ruby/blob/main/docs/writing-functions.md) for more information.

## Local development
Install Ruby 3.0.0 with `rbenv` or `rvm` as this is the targeted version in production.
Also install bundler 2.2.26 which is currently the version used by Google Cloud Build.
```diff
ruby -v
> ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [arm64-darwin21]
bundler -v
> Bundler version 2.2.26
```

Generate a [Twitter Bearer Token](https://developer.twitter.com/en/docs/authentication/oauth-2-0/bearer-tokens)
and store it in a local `env.sh` file.

Note: the example below contains a decommissioned token.

```bash
#!/bin/bash
export BEARER_TOKEN=AAAAAAAAAAAAAAAAAAAAAMLheAAAAAAA0%2BuSeid%2BULvsea4JtiGRiSDSJSI%3DEUifiRBkKG5E2XzMDjRfl76ZC9Ub0wnz4XsNiRVBChTYbJcE3F
```

Install the bundle, and start the framework.
```
bundle install

source env.sh
bundle exec functions-framework-ruby --target status
```

In a separate shell, send requests to this function using curl.
```
curl http://localhost:8080 | jq
```

## Run linter
```
bundle exec standardrb --fix
```

## Run tests
```
bundle exec rspec -fd
```
