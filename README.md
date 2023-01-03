# Caltrain status as a JSON feed

Caltrain published status from Twitter on [their website](https://www.caltrain.com/alerts?active_tab=service_alerts_tab).
It would be much more useful as a JSON. Let's fix that.

We set this up with [Functions Framework for Ruby](https://github.com/GoogleCloudPlatform/functions-framework-ruby).

The feed is published [here](https://us-central1-next-caltrain-pwa.cloudfunctions.net/status).

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

## Secret management

We need to [set up secrets](https://cloud.google.com/functions/docs/configuring/secrets#console) and use the
[Secret Manager client libraries](https://cloud.google.com/secret-manager/docs/reference/libraries#client-libraries-install-ruby).
