## Airbyte Set up with Terraform for GCP

### The basic infrastructure setup for GCPto spin up an Airbyte instance using a service account.

### GCP Authentication

1. Create a service account (manually).
2. Create a key.
3. Download the JSON file as service_account.json and keep it in the root directory.

```
# Set the correct project variable
gcloud config set project <PROJECT_ID>

# Create the service account
gcloud iam service-accounts create terraform \
  --description="Service Account to use with Terraform"

# Create the key file
gcloud iam service-accounts keys create service_account.json \
  --iam-account=terraform@<PROJECT_ID>.iam.gserviceaccount.com

# Grant the Editor role
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role=roles/editor

# Grant the Security Admin role
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=serviceAccount:terraform@<PROJECT_ID>.iam.gserviceaccount.com \
  --role=roles/iam.securityAdmin
  ```