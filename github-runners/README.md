# GitHub Runner Deployment with Argo CD

This directory contains the Kubernetes manifests that provision self-hosted
GitHub Actions runners on Kubernetes using
[actions-runner-controller](https://github.com/actions/actions-runner-controller).
They are designed to be deployed by Argo CD without Kustomize.

## Prerequisites

1. Argo CD installed in your cluster and configured with the `argocd` namespace.
2. A functional GitHub personal access token (PAT) with `admin:org` scope for
   organization runners.
3. The `actions-runner-controller` Argo CD application defined in
   `../argocd/applications/actions-runner-controller.yaml` synced first so the
   CRDs exist before these manifests are applied.
4. [External Secrets Operator](https://external-secrets.io/) installed in the
   cluster with a configured `ClusterSecretStore` named
   `github-runner-secrets` that surfaces your GitHub credentials. Adjust the
   name in the manifests if you use a different store.

## Configuration

Update the following placeholders before syncing the application:

- `jLemmings`: Update the organization value in `runnerdeployment.yaml` and
  `horizontalrunnerautoscaler.yaml` if your GitHub organization differs.
- `github-runner-secrets`: Update the `secretStoreRef` in the ExternalSecret
  manifests if you use a different `SecretStore` name.
- `org-runner`: Replace the `remoteRef.key` value with the path to the
  credentials inside your secret store. Both the controller manager and runner
  ExternalSecrets reference the same key, which must expose a `github_token`
  property containing the PAT.
- `https://github.com/jLemmings/WODRepLog.git`: Update the Argo CD application at
  `../argocd/applications/github-runners.yaml` with the repository URL that
  contains this folder if it differs.

## Deploying with Argo CD

1. Add this repository to Argo CD (if it is not already registered).
2. Apply both application manifests:

   ```bash
   kubectl apply -f argocd/applications/actions-runner-controller.yaml
   kubectl apply -f argocd/applications/github-runners.yaml
   ```

3. In the Argo CD UI or CLI, sync the `actions-runner-controller` application
   first.
4. Once the controller is healthy, sync the `github-runners` application. Argo
   CD will create:

   - The `actions-runner-system` namespace
   - External Secrets that pull your GitHub token(s) from the configured secret
     store
   - A `RunnerDeployment` pre-scaled to three pods
   - A `HorizontalRunnerAutoscaler` that scales between three and six runners
     based on workflow queue length

5. Trigger a workflow in any repository within the `jLemmings` organization and
   observe pods labeled `app=github-runner` spinning up in the namespace.

## Customisation

- Adjust `replicas` in `runnerdeployment.yaml` to change the baseline number of
  runners.
- Modify the autoscaler thresholds in `horizontalrunnerautoscaler.yaml` to tune
  responsiveness to queued jobs.
- Extend the manifests with additional environment variables to mount Docker
  registry credentials, Kubernetes service accounts, or custom runner images as
  required by your workloads.
