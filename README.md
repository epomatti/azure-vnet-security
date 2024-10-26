# Azure VNET Security

This exercise will demonstrate deployability of resources based on subnet status.

Create the variables file:

```sh
cp config/template.tfvars .auto.tfvars
```

Set your public IP address in the `allowed_source_address_prefixes` variable using CIDR notation:

```sh
# allowed_source_address_prefixes = ["1.2.3.4/32"]
curl ifconfig.io/ip
```

Create the keys:

```sh
mkdir keys && ssh-keygen -f keys/temp_rsa
```

Check for updated agent versions:

```sh
# Identify latest version of Network Watcher extension for Linux.
az vm extension image list --name 'NetworkWatcherAgentLinux' --publisher 'Microsoft.Azure.NetworkWatcher' --latest --location 'eastus2'
```

Create the base resources:

> [!NOTE]
> Request might fail if there is already a Network Watched created for the region. Adapt accordingly.

```sh
terraform init
terraform apply -auto-approve
```

## Network Monitor

To enabled advanced monitoring capabilities, such as the [Connection Monitor][2], use the [Network Watcher Agent][1].

This project already installs the agent by default.

You can enable the Connection Monitor from the Azure Monitor Insights section for the Network blade.

## Azure VNET Subnet Delegation

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

## Application Security Group (ASG)

> All network interfaces assigned to an application security group have to exist in the same virtual network that the first network interface assigned to the application security group is in. For example, if the first network interface assigned to an application security group named _AsgWeb_ is in the virtual network named _VNet1_, then all subsequent network interfaces assigned to _ASGWeb_ must exist in _VNet1_. You can't add network interfaces from different virtual networks to the same application security group.

Here're some commands to test [ASGs][3].

Although not mentioned explicitly, you cannot use an ASG created in a different region.

```sh
# Creating in different regions to test compatibility

# You can add this one
az network asg create -g rg-test001 -n asg-test001-eastus2 -l eastus2

# You CANNOT add this one as it is from a different region
az network asg create -g rg-test001 -n asg-test001-brazilsouth -l brazilsouth
```

## Service Tags

Testing the `Internet` service tag via NSG.



---

### Clean up the resources

Destroy the resources after using it:

```sh
terraform destroy -auto-approve
```


[1]: https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/network-watcher-linux
[2]: https://learn.microsoft.com/en-us/azure/network-watcher/connection-monitor-overview
[3]: https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups
