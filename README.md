# Generic DHP Application

Helm Chart to be used for all DHP Applications (or at least as many as possible)

Deploying this Helm Chart does the following:
  - Starts an initialization container which authenticates to Vault
  - Populates template files and environment variables based on Vault Secrets
    - The Secrets to retrieve and template files / environment variables to populate are defined in Helm `values.yaml` files
  - Launches the main application container
    - The image used for this container is defined via Helm `values.yaml` files
  - Monitors the specified Vault Secrets
    - When any of these Secrets change, template files / environment variables are re-rendered and the application is restarted
