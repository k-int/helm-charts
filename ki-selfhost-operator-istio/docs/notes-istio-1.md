Yes—you can keep the http://okapi/<service>/... style and still get Istio’s tenant-aware version routing without touching your apps.

The trick is to make okapi a logical host inside the mesh (a K8s Service only for DNS) and put all the path-prefix + tenant logic in one or more VirtualServices. Callers keep using http://okapi/...; the caller’s sidecar does the routing.

1) Create a logical “okapi” Service (DNS only)
apiVersion: v1
kind: Service
metadata:
  name: okapi
  namespace: my-ns
spec:
  clusterIP: None        # headless: just gives you the DNS name "okapi"
  ports:
  - name: http
    port: 80
Now any pod in my-ns can GET http://okapi/... and Envoy can match rules for host okapi.

2) Route by path prefix (which service) and tenant (which version)
If your apps already serve under the same prefix (e.g., catalog serves /catalog/..., holds serves /holds/...), you don’t need rewrites. Just steer by prefix → service, then header → version/subset.

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: okapi-router
  namespace: my-ns
spec:
  hosts:
    - okapi
    - okapi.my-ns.svc.cluster.local
  http:
    # ---- /catalog ----
    - match:
        - uri: { prefix: "/catalog" }
          # Use whichever header you standardize on:
          # x-tenant-id (raw) or x-service-version (resolved)
          # Example: resolved header
          headers:
            x-service-version:
              exact: v242
      route:
        - destination:
            host: catalog.my-ns.svc.cluster.local
            subset: v242
    - match:
        - uri: { prefix: "/catalog" }
          headers:
            x-service-version:
              exact: v250
      route:
        - destination:
            host: catalog.my-ns.svc.cluster.local
            subset: v250
    - match:
        - uri: { prefix: "/catalog" }
      route:
        - destination:
            host: catalog.my-ns.svc.cluster.local
            subset: v242   # fallback / LTS

    # ---- /holds ----
    - match:
        - uri: { prefix: "/holds" }
          headers:
            x-service-version:
              exact: v183
      route:
        - destination:
            host: holds.my-ns.svc.cluster.local
            subset: v183
    - match:
        - uri: { prefix: "/holds" }
      route:
        - destination:
            host: holds.my-ns.svc.cluster.local
            subset: v180
If a backend expects no prefix (some teams do), add a rewrite under each match:

rewrite: { uri: "/" }   # or strip "/catalog" only with a regex if needed
3) Define version subsets once per service
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: catalog
  namespace: my-ns
spec:
  host: catalog.my-ns.svc.cluster.local
  subsets:
    - name: v242
      labels: { app: catalog, version: "2-4-2" }
    - name: v250
      labels: { app: catalog, version: "2-5-0" }
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: holds
  namespace: my-ns
spec:
  host: holds.my-ns.svc.cluster.local
  subsets:
    - name: v183
      labels: { app: holds, version: "1-8-3" }
    - name: v180
      labels: { app: holds, version: "1-8-0" }
Deployments for each version carry the matching labels.

4) Keep your resolver/ext_authz enrichment (optional)
If you’re enriching anonymous requests with a resolver (ext_authz) to set x-service-version, it still works:

At ingress → your resolver sets x-service-version.

For intra-mesh calls, add ext_authz on SIDECAR_OUTBOUND (scoped to callers), so the caller’s sidecar adds x-service-version before routing to okapi.

Your apps continue calling http://okapi/catalog/...; they just forward x-tenant-id (if you enrich outbound), or nothing at all if you enriched at ingress and preserve the computed header.

5) (Nice-to-have) Delegate per-prefix for sanity
With many services, split config:

A root VS for host okapi that only does prefix matches and delegates.

Child VS per service (okapi-catalog, okapi-holds) that contain the header→subset rules. This keeps xDS small and diffs readable.

6) Scope and performance
Add a Sidecar resource to limit outbound config to hosts your workload needs:

apiVersion: networking.istio.io/v1beta1
kind: Sidecar
metadata:
  name: caller-sidecar
  namespace: my-ns
spec:
  workloadSelector:
    labels: { app: catalog }   # this caller
  egress:
    - hosts:
        - "./okapi.my-ns.svc.cluster.local"
        - "my-ns/*"            # or narrow further
Always include a default subset for safety when the resolver is slow/unavailable.

Result
Your services keep using http://okapi/<service>/... internally.

Istio routes by path prefix to the right logical service and by tenant/version header to the correct version subset—exactly mirroring your legacy gateway behavior, but now fully mesh-native and client-side.


