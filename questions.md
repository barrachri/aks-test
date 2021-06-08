## What are things to watch out for? 

There are so many things to watch out for or that need to be clarified

Project level:
- Is this project a prototype where fast interaction is more important than 99.9 availability?

At the cluster level:
- What kind of availability k8s needs to have? regional? multi-regional? 

Security requirements:
- Can we pull public images? Are outbound connections allowed?

Access requirements:
- Do data scientists and machine learning engineers need access to the cluster?

## How would you run the commands on a factory resetted Ubuntu computer?

In that case, we could use a simple script to `wget` terraform and run terraform plan, and then terraform apply.

## How would you add GPU nodes to the cluster?

I'd add a new node pool to the cluster with terraform, and set taints and labels to only schedule specific workloads on those nodes.

## Write a Yaml (or Helm Chart) to deploy a simple TLS Secured hello world webservice inside the Kubernetes cluster. What are important points to consider?

> Check deployment/

First, is it an internal service or is exposed publicly?

Is the TLS certificate manually generated or generated through let's encrypt?

Depending on the answer there are different things to consider.

If it's an internal service a k8s deployment and service might work well.

If there's an ingress and ingress route must also be added.

In both scenarios and TLS certificate must be added through secrets.

In case it's an exposed service the deployment would need a k8s deployment, service, and update to the ingress route.

In this case, the TLS certificate can be generated through cert-manager, otherwise must be available as a secret.

About the application there a few things to consider:

- can we set probes?
- can we set meaningful labels?
- what are the cpu and memory requirements?
- Is the application stateless?
- Does the application requires a specific resource (GPU or mounted volume)?

These are the things I'd consider.

## Write a Github Action or Azure Devops Pipeline (whichever you are more comfortable with) to deploy and update the app. What update strategies would you recommend for the Use Case presented in the introduction?

> Check .github/workflows/app.yaml

The app.yaml includes a Github action to run build and linters on every pull request.

The deployment to, hypothetically dev environment, would happen only on the main branch (after a merge).

This strategy could be extended for multiple environments (staging or production) by using a release/tag approach on Github and using a one-click deploy button with Azure Devops.

Given the requirement `required to be constantly connected to a complex backend`, any deployment should be orchestrated as zero-downtime deployment.

Using kubernetes rollout strategies together with proper handling of signal inside the application.

## Write a Github Action or Azure Devops Pipeline (whichever you are more comfortable with) to update the cluster itself. What important things should be watched out for before updating nodes? What are limitations?

> Check .github/workflows/infrastructure.yaml

You don't want to destroy the cluster and in case you are changing nodes you want to create a new pool (and wait for the workloads to move) before destroying old ones.

You could rely on the terrafrom `create_before_destroy` lifecycle, but I would feel much more confident with adding new nodes first, setting old ones as drained, and removing them in a 2nd PR after all the workload has been moved.

## How would you document the steps to get someone new onboarded to your infrastructure and keep it in sync with every stage? (dev/test/prod)

First, dev, test, and prod should be fairly similar to each other. And similar procedures should apply to all of them.

Then we should differentiate between users that are not expected to touch the infrastructure frequently and users that would constantly work on the infrastructure.


For the former common use-cases should be documented (like how-to guides) for users that are not familiar with terraform (like adding a new role or assignment)

For the latter documentation and onboarding tasks should 

The documentation should cover:
- explain modules organization and where to look for things
- explaining naming convention
- explaing how to contribute
- explain the release process for each env

Onboarding steps:

- 1st pull request for trivial changes
- release to dev/test/prod
- 2nd pull request for non-trivial changes
- 3nd pull request for non-trivial changes

A critical part of the onboarding process is to gather feedback and improve the onboarding itself.

So if anything appears to be outdated (documentation) or doesn't work like expected (onboarding steps) it's fundamental to fix them accordingly. 

## A developer complains to you that they need a local deployment of the whole backend (or a mock of it) on their local desktop. How would you help them solve their issue?

It depends on the meaning of the `whole backend` and on the interaction that they need to have if there are multiple components or cloud services.

You can use docker and docker-compose compose to replicate some services, but you don't have a cluster running locally.
The other option is to have a real cluster running locally, kubernetes for docker (windows and os x) can help with this.
Another option would be to use k3d to run a micro Kubernetes distribution.

## Explain how you would implement a monitoring strategy for the system and how you would deploy & maintain it?

First, we need to define a monitoring strategy for cluster health.

This could include the number of nodes available, nodes cpu/memory available, unscheduled pods, last error events for example.

The next step is to come up together with the application team for metrics that can describe when the application is workings correctly or not.

In the case of event processing, interesting metrics can be the number of events/sec, number of errors, and p95 latency.

From there I'd iterate, to avoid false-positive and have metrics that can signal problems before actually having a downtime.

From the technical perspective, you could run grafana + prometheus or Influx or use the available solution from Azure. 

If you go with Grafana + Prom or Influx then you'd have to decide whether you want to run it o you want to use their managed services.

Apart from the cost, the other thing to factor in is the maintenance overhead of running your monitoring stack.

In case we want to run it, I'd deploy and maintain it exactly like any other application.

Using a separate repo, with yamls , helm or terraform to describe how to deploy the monitoring stack.
