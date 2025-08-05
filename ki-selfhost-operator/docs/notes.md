
### ✅ You're Following the Correct API Group

You're following this guide:

> [https://developer.konghq.com/operator/dataplanes/how-to/deploy-custom-plugins/](https://developer.konghq.com/operator/dataplanes/how-to/deploy-custom-plugins/)

And it uses:

```yaml
apiVersion: gateway-operator.konghq.com/v1beta1
kind: GatewayConfiguration
```

That is **not the same CRD** as:

```yaml
apiVersion: operator.konghq.com/v1beta1
kind: KongGatewayConfiguration
```

The **correct CRD** for **Kong Gateway Operator ≥1.6.x** is:

```yaml
apiVersion: gateway-operator.konghq.com/v1beta1
kind: GatewayConfiguration
```

This confusion arises because older docs and some unofficial content used the earlier `KongGatewayConfiguration` from the Operator API group. That is **deprecated or invalid** in modern setups.

---

### ✅ Correct Resource Names in Kong Gateway Operator v1.6.x+

| Purpose                          | Resource Kind          | API Group                             |
| -------------------------------- | ---------------------- | ------------------------------------- |
| Declare runtime config for proxy | `GatewayConfiguration` | `gateway-operator.konghq.com/v1beta1` |
| Bind config to routes            | `GatewayClass`         | `gateway.networking.k8s.io/v1beta1`   |
| Deploy gateway pods              | `DataPlane`            | `operator.konghq.com/v1beta1`         |
| Enable plugin                    | `KongPlugin`           | `configuration.konghq.com/v1`         |

---

### 🔁 Updated: Correct YAML Using `GatewayConfiguration`

Here's the corrected version of that resource, matching the **guide you're following**.

---

## ✅ `01-gateway-configuration.yaml` (✅ CORRECT API VERSION)

```yaml
apiVersion: gateway-operator.konghq.com/v1beta1
kind: GatewayConfiguration
metadata:
  name: ki-selfhost-gw-config
  namespace: kong-system
spec:
  proxy:
    container:
      image: docker.libsdev.k-int.com/knowledgeintegration/kong-ki-selfhost-router:latest
      env:
        - name: KONG_LOG_LEVEL
          value: debug
      containerPlugins:
        - kong-ki-selfhost-router
```

> ✅ This is what **tells the DataPlane what image and plugins to use**.

Then your `GatewayClass` should point to it like this:

---

## ✅ `02-gateway-class.yaml`

```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: GatewayClass
metadata:
  name: kong-ki-selfhost-gw-class
spec:
  controllerName: gateway-operator.konghq.com/kong-gateway-controller
  parametersRef:
    group: gateway-operator.konghq.com
    kind: GatewayConfiguration
    name: ki-selfhost-gw-config
    namespace: kong-system
```

---

### ✅ What This Means for You

* The **guide you're following is correct for v1.6+** (you were right).
* You **do not need** to create a `DataPlane` resource directly. It is **automatically managed** by the Operator based on the `GatewayConfiguration` and `GatewayClass`.
* Plugin enablement happens via `containerPlugins` inside the `GatewayConfiguration`, not in a `DataPlane`.

> 🔁 My earlier suggestion to use `DataPlane` was based on earlier patterns or direct use of `operator.konghq.com` CRDs. You are following the **newest architecture** that removes that burden.

---

### ✅ Final TL;DR

| You Asked                                                  | Answer                                                       |
| ---------------------------------------------------------- | ------------------------------------------------------------ |
| Is `gateway-operator.konghq.com/v1beta1` valid?            | ✅ Yes, it's the correct API group for modern KGO             |
| Should I use `KongGatewayConfiguration`?                   | ❌ No, that's outdated or incorrect for your version          |
| Do I need to manually create a `DataPlane`?                | ❌ No, the operator does this based on `GatewayConfiguration` |
| Is `containerPlugins` valid inside `GatewayConfiguration`? | ✅ Yes, this is now how you register your plugin              |

