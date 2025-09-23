param containerAppName string
param location string 
param environmentName string 
param containerImage string
param containerPort int
@allowed([ '/health', '/health/live', '/health/ready', '/health/startup' ])
param probePathLiveness string = '/health/live'
@allowed([ '/health', '/health/live', '/health/ready', '/health/startup' ])
param probePathReadiness string = '/health/ready'
@allowed([ '/health', '/health/live', '/health/ready', '/health/startup' ])
param probePathStartup string = '/health/startup'
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param isPrivateRegistry bool
param enableIngress bool 
@secure()
param registryPassword string
param minReplicas int = 0
param secrets array = []
param env array = []
param revisionMode string = 'Single'


resource environment 'Microsoft.App/managedEnvironments@2025-01-01' existing = {
  name: environmentName
}

resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: containerAppName
  location: location
  properties: {
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: secrets
      registries: isPrivateRegistry ? [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: registryPassword
        }
      ] : null
      ingress: enableIngress ? {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      } : null
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
          // health probes: uses HTTP GET against the container port at configured paths
          probes: [
            {
              type: 'Liveness'
              httpGet: {
                path: probePathLiveness
                port: containerPort
              }
              initialDelaySeconds: 30
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 3
              successThreshold: 1
            }
            {
              type: 'Readiness'
              httpGet: {
                path: probePathReadiness
                port: containerPort
              }
              initialDelaySeconds: 5
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 3
              successThreshold: 1
            }
            {
              type: 'Startup'
              httpGet: {
                path: probePathStartup
                port: containerPort
              }
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 30
              successThreshold: 1
            }
          ]
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
