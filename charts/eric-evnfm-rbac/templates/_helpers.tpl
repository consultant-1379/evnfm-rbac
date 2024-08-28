{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eric-evnfm-rbac.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-evnfm-rbac.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create keycloak-client image registry url
*/}}
{{- define "eric-evnfm-rbac.keycloak-client.registryUrl" -}}
  {{- include "eric-eo-evnfm-library-chart.mainImagePath" (dict "ctx" . "svcRegistryName" "keycloakClient") -}}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-evnfm-rbac.kubernetes-io-info" -}}
  {{- include "eric-eo-evnfm-library-chart.kubernetes-io-info" . -}}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-evnfm-rbac.helm-annotations" -}}
  {{- include "eric-eo-evnfm-library-chart.helm-annotations" . -}}
{{- end}}

{{/*
Create keycloak-client image pull secrets
*/}}
{{- define "eric-evnfm-rbac.keycloak-client.pullSecrets" -}}
  {{- include "eric-eo-evnfm-library-chart.pullSecrets" . -}}
{{- end -}}

{{/*
Enable Node Selector functionality
*/}}
{{- define "eric-evnfm-rbac.nodeSelector" -}}
  {{- include "eric-eo-evnfm-library-chart.nodeSelector" . -}}
{{- end -}}

{{/*
Create pullPolicy for crypto service container
*/}}
{{- define "eric-evnfm-rbac.imagePullPolicy" -}}
  {{- include "eric-eo-evnfm-library-chart.imagePullPolicy" (dict "ctx" . "svcRegistryName" "keycloakClient") -}}
{{- end -}}

{{/*
Create domain-role access control config
*/}}
{{- define "eric-evnfm-rbac.drac.domainRoles" -}}
  {{- if index .Values "eric-eo-evnfm-drac" "enabled" -}}
        {{- if index .Values "eric-eo-evnfm-drac" "domainRoles" -}}
            {{- range $k, $role := index .Values "eric-eo-evnfm-drac" "domainRoles" -}}{{ if ne $k 0 }},{{ end }}
              {
                "name": {{ $role.name | quote }},
                "nodeTypes": [
                  {{- range $key, $nodeType := $role.nodeTypes }}{{ if ne $key 0 }},{{ end }}
                  {{ $nodeType | quote }} {{ end -}}
                ]
              }
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}

{{- define "eric-evnfm-rbac.tolerations" -}}
{{- $tolerations := list -}}
{{- if .Values.tolerations -}}
  {{- if .Values.tolerations.rbac -}}
    {{- if ne (len .Values.tolerations.rbac) 0 -}}
      {{- range $t := .Values.tolerations.rbac -}}
        {{- $tolerations = append $tolerations $t -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- if .Values.global -}}
  {{- if .Values.global.tolerations -}}
    {{- if ne (len .Values.global.tolerations) 0 -}}
      {{- range $t := .Values.global.tolerations -}}
        {{- $tolerations = append $tolerations $t -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{ toYaml $tolerations }}
{{- end -}}

{{/*
Create Ericsson product specific annotations
*/}}
{{- define "eric-evnfm-rbac.helm-annotations_product_name" -}}
  {{- include "eric-eo-evnfm-library-chart.helm-annotations_product_name" . -}}
{{- end -}}

{{- define "eric-evnfm-rbac.helm-annotations_product_number" -}}
  {{- include "eric-eo-evnfm-library-chart.helm-annotations_product_number" . -}}
{{- end -}}

{{- define "eric-evnfm-rbac.helm-annotations_product_revision" -}}
  {{- include "eric-eo-evnfm-library-chart.helm-annotations_product_revision" . -}}
{{- end -}}

{{/*
Create a dict of annotations for the product information (DR-D1121-064, DR-D1121-067).
*/}}
{{- define "eric-evnfm-rbac.product-info" }}
ericsson.com/product-name: {{ template "eric-evnfm-rbac.helm-annotations_product_name" . }}
ericsson.com/product-number: {{ template "eric-evnfm-rbac.helm-annotations_product_number" . }}
ericsson.com/product-revision: {{ template "eric-evnfm-rbac.helm-annotations_product_revision" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "eric-evnfm-rbac.annotations" -}}
  {{- $productInfo := include "eric-evnfm-rbac.helm-annotations" . | fromYaml -}}
  {{- $globalAnn := (.Values.global).annotations -}}
  {{- $serviceAnn := .Values.annotations -}}
  {{- include "eric-eo-evnfm-library-chart.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $globalAnn $serviceAnn)) | trim }}
{{- end -}}

{{/*
  Create chart version as used by the chart label.
*/}}
{{- define "eric-evnfm-rbac.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
DR-D470217-011 This helper defines the annotation which bring the service into the mesh.
*/}}
{{- define "eric-evnfm-rbac.service-mesh-inject" }}
  {{- include "eric-eo-evnfm-library-chart.service-mesh-inject-job" . -}}
{{- end -}}

{{/*
Kubernetes labels
*/}}
{{- define "eric-evnfm-rbac.kubernetes-labels" -}}
app.kubernetes.io/name: {{ include "eric-evnfm-rbac.name" . }}
{{ include "eric-evnfm-rbac.service-mesh-inject" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/version: {{ include "eric-evnfm-rbac.version" . }}
{{- end -}}

{{/*
  Common labels
*/}}
{{- define "eric-evnfm-rbac.labels" -}}
{{- $kubernetesLabels := include "eric-evnfm-rbac.kubernetes-labels" . | fromYaml -}}
{{- $globalLabels := (.Values.global).labels -}}
{{- $serviceLabels := .Values.labels -}}
{{- include "eric-eo-evnfm-library-chart.mergeLabels" (dict "location" .Template.Name "sources" (list $kubernetesLabels $globalLabels $serviceLabels)) }}
{{- end -}}

{{/*
  Merged labels for extended defaults
*/}}
{{- define "eric-evnfm-rbac.labels.extended-defaults" -}}
{{- $extendedLabels := dict -}}
{{- $_ := set $extendedLabels "app" (include "eric-evnfm-rbac.name" .) -}}
{{- $_ := set $extendedLabels "chart" (include "eric-evnfm-rbac.chart" .) -}}
{{- $_ := set $extendedLabels "logger-communication-type" "direct" -}}
{{- $_ := set $extendedLabels "release" (.Release.Name) -}}
{{- $_ := set $extendedLabels "heritage" (.Release.Service) -}}
{{- $commonLabels := include "eric-evnfm-rbac.labels" . | fromYaml -}}
{{- include "eric-eo-evnfm-library-chart.mergeLabels" (dict "location" .Template.Name "sources" (list $commonLabels $extendedLabels)) | trim }}
{{- end -}}


{{- if .Values.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.terminationGracePeriodSeconds.keycloakClient | int }}
{{- end }}

{{/*
    Template defining the Authorization Proxy sidecars
    Version: eric-sec-authorization-proxy-oauth2-1.18.0-10
*/}}

{{/*
Create template for auth proxy labels; version and app selector,
template is included in SP _product_label and so attached to all k8s objects
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-labels" -}}
{{ "authpxy.version: " -}}{{- "eric-sec-authorization-proxy-oauth2-1.18.0-10" | trunc 63 | trimSuffix "-" }}
authpxy.app: "authz-proxy-library"
{{- end -}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-global" -}}
  {{- $globalDefaults := dict "security" (dict "tls" (dict "enabled" true)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "oamNodeID" "node-id-not-set") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "log" (dict "outputs" (list "k8sLevel"))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{- if .Values.global -}}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{- else -}}
    {{- $globalDefaults | toJson -}}
  {{- end -}}
{{- end -}}

{{/*
Create a map from ".Values.authorizationProxy" with defaults if missing in values file.
Note default values for ".resources" are handled in separate template "eric-evnfm-rbacauthz-proxy-resources"
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-values" -}}
  {{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
  {{- $authzproxyDefaults := dict "enabled" true -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "protectedPaths" (list "/ah/api/")) -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamServiceName" "eric-sec-access-mgmt") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIccrServiceName" "eric-tm-ingress-controller-cr") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIccrCaSecret" "") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamServicePort" "") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamAdminConsolePort" "8444") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamRealm" "oam") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamAdminSecret" "eric-sec-access-mgmt-creds") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "adpIamClientCredentialSecret" "eric-sec-access-mgmt-aapxy-creds") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "port" "8888") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "suffixOverride" "authproxy") -}}
  {{- if $global.security.tls.enabled -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "localSpClientCertVolumeName" "tls-client-cert2-volumemount") -}}
  {{- else -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "localSpClientCertVolumeName" "") -}}
  {{- end -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "numOfWebServerWorkers" "2") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "service" (dict "endpoints" (dict "authorizationProxy" (dict "tls" (dict "enforced" "required"))))) -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "service" (dict "endpoints" (dict "authorizationProxy" (dict "tls" (dict "verifyClientCertificate" "optional"))))) -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "iamRequestTimeout" "8") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "spRequestTimeout" "8") -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "authzLog" (dict "logtransformer" (dict "host" "eric-log-transformer"))) -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "metrics" (dict "enabled" true )) -}}
  {{- $authzproxyDefaults := merge $authzproxyDefaults (dict "sipoauth2" (dict "enabled" false )) -}}
  {{- if .Values.authorizationProxy -}}
    {{/*
    The two following lines is to take service values from
    .Values.service instead of .Values.authorizationProxy.service
    */}}
    {{- $service := mergeOverwrite $authzproxyDefaults.service .Values.service -}}
    {{- $authzproxyDefaults = set $authzproxyDefaults "service" $service -}}
    {{- mergeOverwrite $authzproxyDefaults .Values.authorizationProxy | toJson -}}
  {{- else -}}
    {{- $authzproxyDefaults | toJson -}}
  {{- end -}}
{{- end -}}

{{/*
Create a map from ".Values.probes" with defaults if missing from value file.
This hides defaults from values file.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-probes" -}}
  {{- $probeDefaults := dict dict "ericsecoauthproxy" (dict "startupProbe" (dict "failureThreshold" "25")) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "startupProbe" (dict "periodSeconds" "5"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "startupProbe" (dict "timeoutSeconds" "5"))) -}}
  {{- $startupProbe := semverCompare ">=1.18-0" (printf "%s.%s" .Capabilities.KubeVersion.Major (trimSuffix "+" .Capabilities.KubeVersion.Minor)) }}
  {{- if not $startupProbe }}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "livenessProbe" (dict "initialDelaySeconds" "125"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "readinessProbe" (dict "initialDelaySeconds" "125"))) -}}
  {{- end }}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "livenessProbe" (dict "failureThreshold" "2"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "livenessProbe" (dict "periodSeconds" "5"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "livenessProbe" (dict "timeoutSeconds" "5"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "readinessProbe" (dict "failureThreshold" "1"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "readinessProbe" (dict "periodSeconds" "5"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "readinessProbe" (dict "successThreshold" "1"))) -}}
  {{- $probeDefaults := merge $probeDefaults (dict "ericsecoauthproxy" (dict "readinessProbe" (dict "timeoutSeconds" "5"))) -}}
  {{- if .Values.probes -}}
    {{- mergeOverwrite $probeDefaults .Values.probes | toJson -}}
  {{- else -}}
    {{- $probeDefaults | toJson -}}
  {{- end -}}
{{- end -}}

{{/*
Create a map from ".Values.imageCredentials" with defaults if missing from value file.
This hides defaults from values file.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-imageCreds" -}}
  {{- $imageCredsDefaults := dict "ericsecoauthproxy" (dict "registry" (dict "url" "")) -}}
  {{- $imageCredsDefaults := merge $imageCredsDefaults (dict "ericsecoauthproxy" (dict "registry" (dict "imagePullPolicy" ""))) -}}
  {{- $imageCredsDefaults := merge $imageCredsDefaults (dict "ericsecoauthproxy" (dict "repoPath" "proj-common-assets-cd-released/security")) -}}
  {{- $imageCredsDefaults := merge $imageCredsDefaults (dict "ericsecoauthsap" (dict "registry" (dict "url" ""))) -}}
  {{- $imageCredsDefaults := merge $imageCredsDefaults (dict "ericsecoauthsap" (dict "registry" (dict "imagePullPolicy" ""))) -}}
  {{- $imageCredsDefaults := merge $imageCredsDefaults (dict "ericsecoauthsap" (dict "repoPath" "proj-common-assets-cd-released/security")) -}}
  {{- if .Values.imageCredentials -}}
    {{- mergeOverwrite $imageCredsDefaults .Values.imageCredentials | toJson -}}
  {{- else -}}
    {{- $imageCredsDefaults | toJson -}}
  {{- end -}}
{{- end -}}

{{/*
The eric-sec-oauth-sap image path
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-imagePath" -}}
  {{- include "eric-eo-evnfm-library-chart.mainImagePath" (dict "ctx" . "svcRegistryName" "ericsecoauthsap") -}}
{{- end -}}

{{/*
ImagePullPolicy for sap init container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-imagePullPolicy" -}}
  {{- $imageCredentials := fromJson (include "eric-evnfm-rbac.authz-proxy-imageCreds" .) -}}
  {{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
  {{- if $imageCredentials.ericsecoauthsap.registry.imagePullPolicy -}}
    {{- print $imageCredentials.ericsecoauthsap.registry.imagePullPolicy -}}
  {{- else -}}
    {{- print $global.registry.imagePullPolicy -}}
  {{- end -}}
{{- end -}}

{{/*
The eric-sec-oauth-proxy image path
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-proxy-imagePath" -}}
  {{- include "eric-eo-evnfm-library-chart.mainImagePath" (dict "ctx" . "svcRegistryName" "ericsecoauthproxy") -}}
{{- end -}}

{{/*
ImagePullPolicy for proxy sidecar container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-proxy-imagePullPolicy" -}}
  {{- $imageCredentials := fromJson (include "eric-evnfm-rbac.authz-proxy-imageCreds" .) -}}
  {{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
  {{- if $imageCredentials.ericsecoauthproxy.registry.imagePullPolicy -}}
    {{- print $imageCredentials.ericsecoauthproxy.registry.imagePullPolicy -}}
  {{- else -}}
    {{- print $global.registry.imagePullPolicy -}}
  {{- end -}}
{{- end -}}

{{/*
Authorization Proxy sidecar service port definition
To be used in the k8s service that publishes Authorization Proxy service port.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-service-port" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $isAuthzServerTls := and $global.security.tls.enabled (ne $authorizationProxy.service.endpoints.authorizationProxy.tls.enforced "optional") -}}
{{- if $authorizationProxy.enabled -}}
{{- if $isAuthzServerTls }}
- name: "http-apo2-tls"
{{- else }}
- name: "http-apo2"
{{- end }}
  protocol: TCP
  port: 8080
  targetPort: http-apo2
{{- end -}}
{{- end -}}

{{/*
Authorization Proxy k8s service name
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-service-name" -}}
{{- $serviceprovidername := default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- printf "%s-%s" $serviceprovidername $authorizationProxy.suffixOverride }}
{{- end -}}

{{/*
Authorization Proxy IAM access label
Access to IAM according to pattern 2 network policy configurations
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-iam-access-label" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
  {{- printf "%s-access" ($authorizationProxy.adpIamServiceName) -}}
{{- end -}}

{{/*
Authorization Proxy specific k8s service annotations
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-service-annotations" -}}
{{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- $isAuthzServerTls := and $global.security.tls.enabled (ne $authorizationProxy.service.endpoints.authorizationProxy.tls.enforced "optional") -}}
{{- if and $global.security.tls.enabled $authorizationProxy.enabled -}}
  {{- if $isAuthzServerTls -}}
  projectcontour.io/upstream-protocol.tls: http-apo2-tls,8080
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
DR-D1123-134
Generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-evnfm-rbac.serviceAccount.name" -}}
{{- printf "%s-sa" (include "eric-evnfm-rbac.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
IAM server k8s service port number.
This port will always provide those endpoints that are part of some external
standard supported by IAM server (token endpoint, openid connect endpoints etc.)
By default it will also serve IAM admin REST API (a.k.a admin console).
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-iam-int-port" -}}
{{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.adpIamServicePort -}}
{{ $authorizationProxy.adpIamServicePort | quote }}
{{- else -}}
{{- if $global.security.tls.enabled -}}
"8443"
{{- else -}}
"8080"
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a map for authorization proxy container resources
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-resources" -}}
{{- $resources := dict "ericsecoauthsap" (dict "requests" (dict "cpu" "50m")) -}}
{{- $resources := merge $resources (dict "ericsecoauthsap" (dict "requests" (dict "memory" "130Mi"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthsap" (dict "requests" (dict "ephemeral-storage" ""))) -}}
{{- $resources := merge $resources (dict "ericsecoauthsap" (dict "limits" (dict "cpu" "50m"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthsap" (dict "limits" (dict "memory" "130Mi"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthsap" (dict "limits" (dict "ephemeral-storage" ""))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "requests" (dict "cpu" "50m"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "requests" (dict "memory" "130Mi"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "requests" (dict "ephemeral-storage" ""))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "limits" (dict "cpu" "150m"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "limits" (dict "memory" "256Mi"))) -}}
{{- $resources := merge $resources (dict "ericsecoauthproxy" (dict "limits" (dict "ephemeral-storage" ""))) -}}

{{- $isTopLevelResouces := false -}}
{{- $isAuthorizationProxyResources := false -}}
{{- if .Values.resources -}}
    {{- $isTopLevelResouces = true -}}
{{- end -}}
{{- if .Values.authorizationProxy -}}
    {{- if .Values.authorizationProxy.resources -}}
        {{- $isAuthorizationProxyResources = true -}}
    {{- end -}}
{{- end -}}

{{- if and $isAuthorizationProxyResources $isTopLevelResouces -}}
    {{- mergeOverwrite $resources .Values.authorizationProxy.resources .Values.resources | toJson -}}
{{- else if $isTopLevelResouces  -}}
    {{- mergeOverwrite $resources .Values.resources | toJson -}}
{{- else if $isAuthorizationProxyResources -}}
    {{- mergeOverwrite $resources .Values.authorizationProxy.resources | toJson -}}
{{- else -}}
    {{- $resources | toJson -}}
{{- end -}}
{{- end -}}


{{/*
Authorization Proxy (sap) init container resource requests and limits
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-resources" -}}
{{- $resources := fromJson (include "eric-evnfm-rbac.authz-proxy-resources" .) -}}
requests:
  {{- if $resources.ericsecoauthsap.requests.cpu }}
  cpu: {{ $resources.ericsecoauthsap.requests.cpu | quote }}
  {{- end }}
  {{- if $resources.ericsecoauthsap.requests.memory }}
  memory: {{ $resources.ericsecoauthsap.requests.memory | quote }}
  {{- end }}
  {{- if index $resources.ericsecoauthsap.requests "ephemeral-storage" }}
  ephemeral-storage: {{ index $resources.ericsecoauthsap.requests "ephemeral-storage" | quote }}
  {{- end }}
limits:
  {{- if $resources.ericsecoauthsap.limits.cpu }}
  cpu: {{ $resources.ericsecoauthsap.limits.cpu | quote }}
  {{- end }}
  {{- if $resources.ericsecoauthsap.limits.memory }}
  memory: {{ $resources.ericsecoauthsap.limits.memory | quote }}
  {{- end }}
  {{- if index $resources.ericsecoauthsap.limits "ephemeral-storage" }}
  ephemeral-storage: {{ index $resources.ericsecoauthsap.limits "ephemeral-storage" | quote }}
  {{- end }}
{{- end -}}

{{/*
Authorization Proxy sidecar container resource requests and limits
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sidecar-resources" -}}
{{- $resources := fromJson (include "eric-evnfm-rbac.authz-proxy-resources" .) -}}
requests:
  {{- if $resources.ericsecoauthproxy.requests.cpu }}
  cpu: {{ $resources.ericsecoauthproxy.requests.cpu | quote }}
  {{- end }}
  {{- if $resources.ericsecoauthproxy.requests.memory }}
  memory: {{ $resources.ericsecoauthproxy.requests.memory | quote }}
  {{- end }}
  {{- if index $resources.ericsecoauthproxy.requests "ephemeral-storage" }}
  ephemeral-storage: {{ index $resources.ericsecoauthproxy.requests "ephemeral-storage" | quote }}
  {{- end }}
limits:
  {{- if $resources.ericsecoauthproxy.limits.cpu }}
  cpu: {{ $resources.ericsecoauthproxy.limits.cpu | quote }}
  {{- end }}
  {{- if $resources.ericsecoauthproxy.limits.memory }}
  memory: {{ $resources.ericsecoauthproxy.limits.memory | quote }}
  {{- end }}
  {{- if index $resources.ericsecoauthproxy.limits "ephemeral-storage" }}
  ephemeral-storage: {{ index $resources.ericsecoauthproxy.limits "ephemeral-storage" | quote }}
  {{- end }}
{{- end -}}

{{/*
Is IAM Server's sip-oauth2 API used for creating SAP client or not.
*/}}
{{- define "eric-evnfm-rbac.sap-cli-used" -}}
{{- $sipOauth2Beta      := .Capabilities.APIVersions.Has "iam.sec.ericsson.com/v1beta1/InternalOAuth2Identity" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if and $authorizationProxy.sipoauth2.enabled $sipOauth2Beta }}
true
{{- else }}
{{- end -}}
{{- end -}}

{{/*
The name of the SAP client in IAM Server.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-cli-name" -}}
{{- printf "%s-%s" (include "eric-evnfm-rbac.authz-proxy-service-name" .) "iam-sap-cli" -}}
{{- end -}}


{{/*
Define the apparmor annotation creation based on input profile and container name
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-getApparmorAnnotation" -}}
{{- $profile := index . "profile" -}}
{{- $containerName := index . "ContainerName" -}}
{{- if $profile.type -}}
{{- if eq "runtime/default" (lower $profile.type) }}
container.apparmor.security.beta.kubernetes.io/{{ $containerName }}: "runtime/default"
{{- else if eq "unconfined" (lower $profile.type) }}
container.apparmor.security.beta.kubernetes.io/{{ $containerName }}: "unconfined"
{{- else if eq "localhost" (lower $profile.type) }}
{{- if $profile.localhostProfile }}
{{- $localhostProfileList := (splitList "/" $profile.localhostProfile) -}}
{{- if (last $localhostProfileList) }}
container.apparmor.security.beta.kubernetes.io/{{ $containerName }}: "localhost/{{ (last $localhostProfileList ) }}"
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define the apparmor annotation for authorization proxy SAP Init container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-container.appArmorAnnotations" -}}
{{- if .Values.appArmorProfile -}}
{{- $profile := .Values.appArmorProfile -}}
{{- if index .Values.appArmorProfile "ericsecoauthsap" -}}
{{- $profile = index .Values.appArmorProfile "ericsecoauthsap" }}
{{- end -}}
{{- include "eric-evnfm-rbac.authz-proxy-getApparmorAnnotation" (dict "profile" $profile "ContainerName" "ericsecoauthsap") }}
{{- end -}}
{{- end -}}

{{/*
Define the apparmor annotation for authorization proxy server container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-container.appArmorAnnotations" -}}
{{- if .Values.appArmorProfile -}}
{{- $profile := .Values.appArmorProfile }}
{{- if index .Values.appArmorProfile "ericsecoauthproxy" -}}
{{- $profile = index .Values.appArmorProfile "ericsecoauthproxy" }}
{{- end -}}
{{- include "eric-evnfm-rbac.authz-proxy-getApparmorAnnotation" (dict "profile" $profile "ContainerName" "ericsecoauthproxy") }}
{{- end -}}
{{- end -}}

{{/*
Define the seccomp security context creation based on input profile (no container name needed since it is already in the containers security profile)
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-getSeccompSecurityContext" -}}
{{- $profile := index . "profile" -}}
{{- if $profile.type -}}
{{- if eq "runtimedefault" (lower $profile.type) }}
seccompProfile:
  type: RuntimeDefault
{{- else if eq "unconfined" (lower $profile.type) }}
seccompProfile:
  type: Unconfined
{{- else if eq "localhost" (lower $profile.type) }}
seccompProfile:
  type: Localhost
  localhostProfile: {{ $profile.localhostProfile }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Define the seccomp security context for authorization proxy SAP Init container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-container.seccompProfile" -}}
{{- if .Values.seccompProfile }}
{{- $profile := .Values.seccompProfile }}
{{- if index .Values.seccompProfile "ericsecoauthsap" }}
{{- $profile = index .Values.seccompProfile "ericsecoauthsap" }}
{{- end }}
{{- include "eric-evnfm-rbac.authz-proxy-getSeccompSecurityContext" (dict "profile" $profile) }}
{{- end -}}
{{- end -}}

{{/*
Define the seccomp security context for authorization proxy server container
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-container.seccompProfile" -}}
{{- if .Values.seccompProfile }}
{{- $profile := .Values.seccompProfile }}
{{- if index .Values.seccompProfile "ericsecoauthproxy" }}
{{- $profile = index .Values.seccompProfile "ericsecoauthproxy" }}
{{- end }}
{{- include "eric-evnfm-rbac.authz-proxy-getSeccompSecurityContext" (dict "profile" $profile) }}
{{- end -}}
{{- end -}}


{{/*
Authorization Proxy SAP init container spec
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-container.spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
{{- $global            := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $sapClientUsed     := include "eric-evnfm-rbac.sap-cli-used" . -}}
- name: ericsecoauthsap
  image: {{ template "eric-evnfm-rbac.authz-proxy-sap-imagePath" . }}
  imagePullPolicy: {{ template "eric-evnfm-rbac.authz-proxy-sap-imagePullPolicy" . }}
  command: ["catatonit", "--"]
  args: ["/sap/sap.py"]
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
{{- include "eric-evnfm-rbac.authz-proxy-sap-container.seccompProfile" . | nindent 4 }}
    capabilities:
      drop:
        - all
  resources:
{{ include "eric-evnfm-rbac.authz-proxy-sap-resources" . | nindent 4 }}
  env:
  - name: SERVICE_NAME
    value: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}
  - name: LOG_STDOUT
    {{- if has "k8sLevel" $global.log.outputs }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: LOG_STREAM
    {{- if has "applicationLevel" $global.log.outputs }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: LOG_LEVEL
    value: {{ .Values.logLevel | default "info" | quote }}
  - name: LOG_TRANSFORMER_HOST
    value: {{ $authorizationProxy.authzLog.logtransformer.host | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_TLS
    {{- if $global.security.tls.enabled }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_REALM_NAME
    value: {{ $authorizationProxy.adpIamRealm }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_INT_ROOT_URI
    value: {{ printf "%s-%s" $authorizationProxy.adpIamServiceName "http" }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_DEFAULT_PORT
    value: {{ template "eric-evnfm-rbac.authz-proxy-iam-int-port" . }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_SECONDARY_PORT
    value: {{ $authorizationProxy.adpIamAdminConsolePort | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_SP_NAME
    value: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}
  - name: TZ
    value: {{ $global.timezone }}
  {{- if $sapClientUsed }}
  - name: IAM_AAPXY_SAP_CLIENT_NAME
    # Note: The value must match with the name of the InternalOAuth2Identity resource
    value: {{ template "eric-evnfm-rbac.authz-proxy-sap-cli-name" . }}
    {{- if not $global.security.tls.enabled }}
  - name: IAM_AAPXY_SAP_SECRET_FILE
    value: /run/secrets/iam-sap-client-secret/client-secret
    {{- end }}
  {{- else }}
  - name: IAM_ADMIN_USER_ID_FILE
    value: /run/secrets/iam-admin-creds/kcadminid
  - name: IAM_ADMIN_PASSWORD_FILE
    value: /run/secrets/iam-admin-creds/kcpasswd
  {{- end }}
  {{- if not $global.security.tls.enabled }}
  - name: CLIENT_SECRET_FILE
    value: /run/secrets/aa-proxy-client-secret/aapxysecret
  {{- end }}
  volumeMounts:
  - name: ericsecoauthsap-tmp
    mountPath: "/tmp"
  - name: authz-proxy-authorizationrules
    mountPath: /sap/config
    readOnly: true
{{- if $global.security.tls.enabled }}
  - name: authz-proxy-iam-client-certificates
    mountPath: /run/secrets/iam-client-certificates
  - name: authz-proxy-sip-tls-root-ca
    mountPath: /run/secrets/sip-tls-root-ca
  {{- if has "applicationLevel" $global.log.outputs }}
  - name: authz-proxy-lt-client-certificates
    mountPath: /run/secrets/lt-client-certificates
  {{- end }}
{{- else }}
  - name: authz-proxy-client-secret
    mountPath: /run/secrets/aa-proxy-client-secret
{{- end }}
{{- if $sapClientUsed }}
  {{- if $global.security.tls.enabled }}
  - name: authz-proxy-iam-sap-client-certificates
    mountPath: /run/secrets/iam-sap-certificates
  {{- else }}
  - name: authz-proxy-sap-client-secret
    mountPath: /run/secrets/iam-sap-client-secret
  {{- end }}
{{- else }}
  - name: authz-proxy-admin-creds
    mountPath: /run/secrets/iam-admin-creds
{{- end }}
{{- end }}
{{- end -}}

{{/*
Authorization Proxy sidecar container spec
The container port number can be changed by adding parameter ".Values.authorizationProxy.port"
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-container.spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
{{- $global            := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $probes           := fromJson (include "eric-evnfm-rbac.authz-proxy-probes" .) -}}
{{- $isAuthzServerTls  := and $global.security.tls.enabled (ne $authorizationProxy.service.endpoints.authorizationProxy.tls.enforced "optional") -}}
- name: ericsecoauthproxy
  image: {{ template "eric-evnfm-rbac.authz-proxy-proxy-imagePath" . }}
  imagePullPolicy: {{ template "eric-evnfm-rbac.authz-proxy-proxy-imagePullPolicy" . }}
  command: ["catatonit", "--"]
  args: ["/authorization-proxy/authz_proxy_server.py"]
  securityContext:
    allowPrivilegeEscalation: false
    privileged: false
    readOnlyRootFilesystem: true
    runAsNonRoot: true
{{- include "eric-evnfm-rbac.authz-proxy-container.seccompProfile" . | nindent 4 }}
    capabilities:
      drop:
        - all
  {{- $startupProbe := semverCompare ">=1.18-0" (printf "%s.%s" .Capabilities.KubeVersion.Major (trimSuffix "+" .Capabilities.KubeVersion.Minor)) }}
  {{- if $startupProbe }}
  startupProbe:
    exec:
      command:
      - /authorization-proxy/probe.sh
      {{- if $isAuthzServerTls }}
      - https://localhost:{{ $authorizationProxy.port }}/authzproxy/watchdog
      {{- else }}
      - http://localhost:{{ $authorizationProxy.port }}/authzproxy/watchdog
      {{- end }}
      - {{ $probes.ericsecoauthproxy.startupProbe.timeoutSeconds | quote }}
    failureThreshold: {{ $probes.ericsecoauthproxy.startupProbe.failureThreshold }}
    timeoutSeconds: {{ $probes.ericsecoauthproxy.startupProbe.timeoutSeconds }}
    periodSeconds: {{ $probes.ericsecoauthproxy.startupProbe.periodSeconds }}
  {{- end }}
  livenessProbe:
    exec:
      command:
      - /authorization-proxy/probe.sh
      {{- if $isAuthzServerTls }}
      - https://localhost:{{ $authorizationProxy.port }}/authzproxy/watchdog
      {{- else }}
      - http://localhost:{{ $authorizationProxy.port }}/authzproxy/watchdog
      {{- end }}
      - {{ $probes.ericsecoauthproxy.livenessProbe.timeoutSeconds | quote }}
    {{- if not $startupProbe }}
    initialDelaySeconds: {{ $probes.ericsecoauthproxy.livenessProbe.initialDelaySeconds }}
    {{- end }}
    timeoutSeconds: {{ $probes.ericsecoauthproxy.livenessProbe.timeoutSeconds }}
    failureThreshold: {{ $probes.ericsecoauthproxy.livenessProbe.failureThreshold }}
    periodSeconds: {{ $probes.ericsecoauthproxy.livenessProbe.periodSeconds }}
  readinessProbe:
    exec:
      command:
      - /authorization-proxy/probe.sh
      {{- if $isAuthzServerTls }}
      - https://localhost:{{ $authorizationProxy.port }}/authzproxy/readiness
      {{- else }}
      - http://localhost:{{ $authorizationProxy.port }}/authzproxy/readiness
      {{- end }}
      - {{ $probes.ericsecoauthproxy.readinessProbe.timeoutSeconds | quote }}
    {{- if not $startupProbe }}
    initialDelaySeconds: {{ $probes.ericsecoauthproxy.readinessProbe.initialDelaySeconds }}
    {{- end }}
    timeoutSeconds: {{ $probes.ericsecoauthproxy.readinessProbe.timeoutSeconds }}
    failureThreshold: {{ $probes.ericsecoauthproxy.readinessProbe.failureThreshold }}
    successThreshold: {{ $probes.ericsecoauthproxy.readinessProbe.successThreshold }}
    periodSeconds: {{ $probes.ericsecoauthproxy.readinessProbe.periodSeconds }}
  resources:
{{ include "eric-evnfm-rbac.authz-proxy-sidecar-resources" . | nindent 4 }}
  env:
  - name: ERIC_SEC_AUTHZ_RPT_TIMEOUT
    value: {{ $authorizationProxy.iamRequestTimeout | quote }}
  - name: ERIC_SEC_AUTHZ_SP_TIMEOUT
    value: {{ $authorizationProxy.spRequestTimeout | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_NODE_ID
    value: {{ $global.oamNodeID | quote }}
  - name: FLASK_ENV
    value: "production"
  - name: SERVICE_NAME
    value: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}
  - name: LOG_STDOUT
    {{- if has "k8sLevel" $global.log.outputs }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: LOG_STREAM
    {{- if has "applicationLevel" $global.log.outputs }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: LOG_LEVEL
    value: {{ .Values.logLevel | default "info" | quote }}
  - name: LOG_TRANSFORMER_HOST
    value: {{ $authorizationProxy.authzLog.logtransformer.host | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_TLS
    {{- if $global.security.tls.enabled }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: ERIC_SEC_AUTHZ_METRICS
    {{- if $authorizationProxy.metrics.enabled }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: ERIC_SEC_AUTHZ_PROXY_SERVER_TLS
    {{- if $isAuthzServerTls }}
    value: "ENABLED"
    {{- else }}
    value: "DISABLED"
    {{- end }}
  - name: ERIC_SEC_AUTHZ_PROXY_VERIFY_CLIENT
    value: {{ $authorizationProxy.service.endpoints.authorizationProxy.tls.verifyClientCertificate }}
  - name: ERIC_SEC_AUTHZ_PROXY_GUNICORN_WORKERS
    value: {{ $authorizationProxy.numOfWebServerWorkers | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_REALM_NAME
    value: {{ $authorizationProxy.adpIamRealm | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_INT_ROOT_URI
    value: {{ printf "%s-%s" $authorizationProxy.adpIamServiceName "http" }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_DEFAULT_PORT
    value: {{ template "eric-evnfm-rbac.authz-proxy-iam-int-port" . }}
  - name: ERIC_SEC_AUTHZ_PROXY_IAM_SECONDARY_PORT
    value: {{ $authorizationProxy.adpIamAdminConsolePort | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_PORT
    value: {{ $authorizationProxy.port | quote }}
  - name: ERIC_SEC_AUTHZ_PROXY_LOCALHOST_SERVICE_URI
    value: "http://localhost:{{ template "eric-evnfm-rbac.restapi.server.single.port" . }}{{/*Add custom localSpPort since we don't want to expose it in the values file*/}}"
  - name: ERIC_SEC_AUTHZ_PROXY_SP_NAME
    value: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}
    {{- if $authorizationProxy.localSpClientCertVolumeName }}
  - name: ERIC_SEC_AUTHZ_PROXY_SP_TLS_CERTS
    value: /run/secrets/local-sp-client-certs
    {{- end }}
  - name: TZ
    value: {{ $global.timezone }}
  ports:
  - containerPort: {{ $authorizationProxy.port }}
    name: http-apo2
  volumeMounts:
  - name: ericsecoauthproxy-tmp
    mountPath: "/tmp"
  - name: ericsecoauthproxy-gunicorn
    mountPath: "/run/gunicorn"
  - name: ericsecoauthproxy-metrics
    mountPath: "/run/metrics"
{{- if $isAuthzServerTls }}
  - name: authz-proxy-server-certificates
    mountPath: /run/secrets/certificates
  - name: authz-proxy-iccr-client-ca-certificate
    mountPath: /run/secrets/iccr-certificates
{{- end }}
{{- if $global.security.tls.enabled }}
  - name: authz-proxy-iam-client-certificates
    mountPath: /run/secrets/iam-client-certificates
  - name: authz-proxy-iam-ca-certificates
    mountPath: /run/secrets/iam-ca-certificates
    {{- if has "applicationLevel" $global.log.outputs }}
  - name: authz-proxy-lt-client-certificates
    mountPath: /run/secrets/lt-client-certificates
    {{- end }}
  - name: authz-proxy-sip-tls-root-ca
    mountPath: /run/secrets/sip-tls-root-ca
  - name: authz-proxy-pm-server-ca
    mountPath: /run/secrets/pm-server-ca
    {{- if $authorizationProxy.localSpClientCertVolumeName }}
  - name: {{ $authorizationProxy.localSpClientCertVolumeName | quote }}
    mountPath: /run/secrets/local-sp-client-certs
    {{- end }}
{{- else }}
  - name: authz-proxy-client-secret
    mountPath: /run/secrets/aa-proxy-client-secret
{{- end }}
{{- end }}
{{- end }}

{{/*
Authorization Proxy volumes, contains the certificates for ingress, log transformer and IAM communication
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-volume.spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
{{- $global             := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $isAuthzServerTls   := and $global.security.tls.enabled (ne $authorizationProxy.service.endpoints.authorizationProxy.tls.enforced "optional") -}}
{{- $sapClientUsed      := include "eric-evnfm-rbac.sap-cli-used" . -}}
- name: ericsecoauthsap-tmp
  emptyDir:
    sizeLimit: "10Mi"
    medium: "Memory"
- name: ericsecoauthproxy-tmp
  emptyDir:
    sizeLimit: "10Mi"
    medium: "Memory"
- name: ericsecoauthproxy-gunicorn
  emptyDir:
    sizeLimit: "10Mi"
    medium: "Memory"
- name: ericsecoauthproxy-metrics
  emptyDir:
    medium: "Memory"
- name: authz-proxy-authorizationrules
  configMap:
    name: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-authorizationrules

{{- if $global.security.tls.enabled }}
- name: authz-proxy-iam-client-certificates
  secret:
    secretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-iam-client-cert
    optional: true
- name: authz-proxy-sip-tls-root-ca
  secret:
    secretName: eric-sec-sip-tls-trusted-root-cert
    optional: true
- name: authz-proxy-iam-ca-certificates
  secret:
    secretName: {{ $authorizationProxy.adpIamServiceName }}-aaproxy-ca-cert
    optional: true
  {{- if $sapClientUsed }}
- name: authz-proxy-iam-sap-client-certificates
  secret:
    secretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-sap-client-cert
    optional: true
  {{- else }}
- name: authz-proxy-admin-creds
  secret:
    secretName: {{ $authorizationProxy.adpIamAdminSecret }}
    optional: true
  {{- end }}
  {{- if has "applicationLevel" $global.log.outputs }}
- name: authz-proxy-lt-client-certificates
  secret:
    secretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-lt-client-cert
    optional: true
  {{- end }}
- name: authz-proxy-pm-server-ca
  secret:
    secretName: eric-pm-server-ca
    optional: true
{{- else }}
- name: authz-proxy-client-secret
  secret:
    secretName: {{ $authorizationProxy.adpIamClientCredentialSecret }}
  {{- if $sapClientUsed }}
- name: authz-proxy-sap-client-secret
  secret:
    secretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-sap-client-secret
  {{- else }}
- name: authz-proxy-admin-creds
  secret:
    secretName: {{ $authorizationProxy.adpIamAdminSecret }}
  {{- end }}
{{- end }}
{{- if $isAuthzServerTls }}
- name: authz-proxy-server-certificates
  secret:
    secretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-server-cert
    optional: true
- name: authz-proxy-iccr-client-ca-certificate
  secret:
    secretName: {{ $authorizationProxy.adpIccrServiceName }}-client-ca
    optional: true
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Authorization Proxy HTTPProxy ingress conditional routing.

The template can only be included from "routes:" yaml element in ICCR HTTPproxy resource.
The resource paths that require authorization must be listed in Values file:
authorizationProxy:protected_paths
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-ingress-routes" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- $global := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
{{- $isAuthzServerTls  := and $global.security.tls.enabled (ne $authorizationProxy.service.endpoints.authorizationProxy.tls.enforced "optional") -}}
{{- if $authorizationProxy.enabled }}
{{- $dot :=  . -}}
{{- $authzServicePort := 8080 -}}
# ----------------------------------------------------------------------
# Authorization proxy specific routing conditions start
# ----------------------------------------------------------------------
{{- range $authorizationProxy.protectedPaths }}
# Conditions for .Values.authorizationProxy.protectedPath: {{ . }}:
# If cookie exists:
- conditions:
  - prefix: {{ . }}
  - header:
      name: Cookie
      contains: eric.adp.authz.proxy.token
  services:
  - name: {{ template "eric-evnfm-rbac.authz-proxy-service-name" $dot }}
    port: {{ $authzServicePort }}
{{- if $isAuthzServerTls }}
    protocol: tls
    validation:
      caSecret: eric-sec-sip-tls-trusted-root-cert
      subjectName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" $dot }}
{{- end }}
# If bearer token exists in authorization header:
- conditions:
  - prefix: {{ . }}
  - header:
      name: Authorization
      contains: Bearer
  services:
  - name: {{ template "eric-evnfm-rbac.authz-proxy-service-name" $dot }}
    port: {{ $authzServicePort }}
{{- if $isAuthzServerTls }}
    protocol: tls
    validation:
      caSecret: eric-sec-sip-tls-trusted-root-cert
      subjectName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" $dot }}
{{- end }}
# No user identity found, route to authentication proxy for authentication:
- conditions:
  - prefix: {{ . }}
  services:
  - name: {{ $authorizationProxy.adpIamServiceName }}-authn
    port: 8080
{{- if $global.security.tls.enabled }}
    protocol: tls
    validation:
      caSecret: eric-sec-sip-tls-trusted-root-cert
      subjectName: {{ $authorizationProxy.adpIamServiceName }}-authn
{{- end }}
{{- end }}
# ----------------------------------------------------------------------
# Authorization proxy specific routing conditions ends
# ----------------------------------------------------------------------
{{- end -}}
{{- end -}}

{{/*
Authorization Proxy Log Transformer client TLS certificate

To be included by the sip-tls CR manifest that creates client certificate
that is used for mutual TLS between authorization proxy/sap and Log Transformer.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-lt-client-cert-spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
kubernetes:
  generatedSecretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-lt-client-cert
  certificateName: clicert.pem
  privateKeyName: cliprivkey.pem
certificate:
  subject:
    cn: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-auth-proxy-lt-client-cert
  issuer:
    reference: "{{ $authorizationProxy.authzLog.logtransformer.host }}-input-ca-cert"
  extendedKeyUsage:
    tlsServerAuth: false
    tlsClientAuth: true
{{- end }}
{{- end -}}

{{/*
Authorization Proxy IAM client TLS certificate

To be included by the sip-tls CR manifest that creates client certificate
that is used for mutual TLS between authorization proxy/sap and IAM server.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-client-cert-spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
kubernetes:
  generatedSecretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-iam-client-cert
  certificateName: clicert.pem
  privateKeyName: cliprivkey.pem
certificate:
  subject:
    cn: adp-iam-aa-client
  extendedKeyUsage:
    tlsServerAuth: false
    tlsClientAuth: true
  issuer:
    reference: {{ $authorizationProxy.adpIamServiceName }}-aaproxy-ca
{{- end }}
{{- end -}}

{{/*
Authorization Proxy server certificate

To be included by the sip-tls CR manifest that creates server certificate
that is used for TLS between authorization proxy and ingress.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-server-cert-spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- if $authorizationProxy.enabled }}
kubernetes:
  generatedSecretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-server-cert
  certificateName: srvcert.pem
  privateKeyName: srvprivkey.pem
certificate:
  subject:
    cn: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}
  subjectAlternativeName:
    dns:
      - certified-scrape-target
  extendedKeyUsage:
    tlsServerAuth: true
    tlsClientAuth: false
{{- end }}
{{- end -}}

{{/*
Authorization Proxy IAM SAP client TLS certificate

To be included by the sip-tls CR manifest that creates SAP client certificate
that is used for mutual TLS between SAP and IAM server.
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-cli-cert-spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
kubernetes:
  generatedSecretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-sap-client-cert
  certificateName: clicert.pem
  privateKeyName: cliprivkey.pem
certificate:
  subject:
    cn: {{ template "eric-evnfm-rbac.authz-proxy-sap-cli-name" . }}
  extendedKeyUsage:
    tlsServerAuth: false
    tlsClientAuth: true
  issuer:
    reference: {{ $authorizationProxy.adpIamServiceName }}-iam-client-ca
{{- end -}}

{{/*
Authorization Proxy IAM SAP client

To be included by the sip-oauth2 CR manifest that creates SAP client in IAM server.
(SAP uses this client when making configuration in IAM server)
*/}}
{{- define "eric-evnfm-rbac.authz-proxy-sap-cli-spec" -}}
{{- $authorizationProxy := fromJson (include "eric-evnfm-rbac.authz-proxy-values" .) -}}
{{- $globals := fromJson (include "eric-evnfm-rbac.authz-proxy-global" .) -}}
realm: {{ $authorizationProxy.adpIamRealm }}
{{- if $globals.security.tls.enabled }}
internalCertificateDnRegex: CN={{ template "eric-evnfm-rbac.authz-proxy-sap-cli-name" . }}
{{- else }}
kubernetes:
  generatedSecretName: {{ template "eric-evnfm-rbac.authz-proxy-service-name" . }}-sap-client-secret
{{- end }}
clientRoles:
  - clientId: realm-management
    roles:
      - query-groups
      - query-clients
      - manage-realm
      - manage-clients
      - manage-authorization
{{- end -}}

{{/*
DR-D470222-010
Configuration of Log Collection Streaming Method
*/}}
{{- define "eric-evnfm-rbac.log.streamingMethod" -}}
{{- $defaultMethod := "dual" }}
{{- $streamingMethod := (.Values.log).streamingMethod }}
    {{- if not $streamingMethod }}
        {{- if (.Values.global.log).streamingMethod -}}
            {{- $streamingMethod = (.Values.global.log).streamingMethod }}
        {{- else -}}
            {{- $streamingMethod = $defaultMethod -}}
        {{- end }}
    {{- end }}

    {{- if or (eq $streamingMethod "direct") (eq $streamingMethod "indirect") }}
        {{- $streamingMethod -}}
    {{- else }}
        {{- $defaultMethod -}}
    {{- end }}
{{- end }}

{{- define "eric-evnfm-rbac.log-streaming-activated" }}
  {{- $streamingMethod := (include "eric-evnfm-rbac.log.streamingMethod" .) -}}
  {{- if or (eq $streamingMethod "dual") (eq $streamingMethod "direct") -}}
    {{- printf "%t" true -}}
  {{- else -}}
    {{- printf "%t" false -}}
  {{- end -}}
{{- end -}}

{{- define "eric-evnfm-rbac.log-storage-path" }}
  {{- if eq "true" (include "eric-evnfm-rbac.log-streaming-activated" .) }}
    {{- $defaultLogshipperValue := fromJson (include "eric-log-shipper-sidecar.log-shipper-sidecar-default-value" .) -}}
    {{- printf $defaultLogshipperValue.logShipper.storage.path -}}
  {{- end -}}
{{- end -}}

{{/*
DR-D1123-134
Rolekind parameter for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-evnfm-rbac.securityPolicy.rolekind" }}
  {{- include "eric-eo-evnfm-library-chart.securityPolicy.rolekind" . }}
{{- end }}

{{/*
DR-D1123-134
Rolename parameter for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-evnfm-rbac.securityPolicy.rolename" }}
  {{- include "eric-eo-evnfm-library-chart.securityPolicy.rolename" . }}
{{- end }}

{{/*
DR-D1123-134
RoleBinding name for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-evnfm-rbac.securityPolicy.rolebinding.name" }}
  {{- include "eric-eo-evnfm-library-chart.securityPolicy.rolebinding.name" . }}
{{- end }}