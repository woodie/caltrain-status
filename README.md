# Caltrain status as a JSON feed

Caltrain published status from Twitter on [their website](https://www.caltrain.com/alerts?active_tab=service_alerts_tab).
We now published a status JSON [here](https://us-central1-next-caltrain-pwa.cloudfunctions.net/status)
that we use in our [Next Caltrain](https://github.com/woodie/next-caltrain-pwa) app.
```
+-----------+
| <marquee> | <- "Train 515 SB is running 10 minutes 
|           |     late approaching Redwood City."
| Train 514 |
| selected  |
+-----------+
```
We set this up with [Functions Framework for Ruby](https://github.com/GoogleCloudPlatform/functions-framework-ruby).
See [Writing Functions](https://github.com/GoogleCloudPlatform/functions-framework-ruby/blob/main/docs/writing-functions.md) for details.

## Local development

Create `env.sh` file to set the `BEARER_TOKEN`.
```bash
#!/bin/bash
export BEARER_TOKEN=NOT_SHOWN
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

## Run tests
```
bundle exec rspec -fd
```

## Secret management

We need to [set up secrets](https://cloud.google.com/functions/docs/configuring/secrets#console) and use the
[Secret Manager client libraries](https://cloud.google.com/secret-manager/docs/reference/libraries#client-libraries-install-ruby).
