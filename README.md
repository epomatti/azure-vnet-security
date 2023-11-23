# Azure VNET Subnet Delegation

This exercise will demonstrate deployability of resources based on subnet status.

Create the base resources:

```sh
terraform init
terraform apply -auto-approve
```

The following subnets will be created within the VNET:

| Subnet | Is empty? | Service Endpoint | Subnet Delegation |
|-|-|-|-|
| Subnet001 | No  | - | - |
| Subnet002 | Yes | `Microsoft.Storage` | - |
| Subnet003 | Yes | - | `Microsoft.Sql/managedInstances` |
| Subnet004 | Yes | - | `Microsoft.Web/serverFarms` |
| Subnet005 | Yes | - | - |


The results are interesting when looking at `Subnet003`.

When integrating services to subnets, we get different outputs:

| Service | Subnet 1 | Subnet 2 | Subnet 3 | Subnet 4 | Subnet 5 |
|-|-|-|-|-|-|
| App Service | ❌ | ✅ | ❌ | ✅ | ✅ |
| SQL MAnaged Instance | ❌ | ✅ | ✅ | ✅ | ✅ |

Requirements for **App Service**:

<img src=".assets/webapp.png" />

Requirements for SQL Managed Instance:

<img src=".assets/sqlmanagedinstance.png" />

---

### Clean up the resources

Destroy the resources after using it:

```sh
terraform destroy -auto-approve
```
