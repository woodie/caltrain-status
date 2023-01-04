
#!/bin/bash

gcloud functions deploy status \
    --project=next-caltrain-pwa \
    --runtime=ruby30 \
    --trigger-http \
    --entry-point=status
