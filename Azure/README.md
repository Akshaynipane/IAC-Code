# Azure Storage Account with Blob Container - Terraform Template

This Terraform template creates an Azure Storage Account with a Blob Storage Container, following security best practices.

## Features

- **Storage Account** with configurable tier and replication
- **Blob Container** with configurable access level
- **Security Features**:
  - HTTPS-only traffic enforcement
  - Minimum TLS 1.2
  - Blob versioning enabled
  - Soft delete for blobs and containers (7-day retention)
  - Network rules with default deny
  - Public blob access disabled by default
- **Outputs** for easy integration with other resources

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- Azure subscription with appropriate permissions

## Authentication

Authenticate with Azure before running Terraform:

```bash
az login
az account set --subscription "your-subscription-id"
```

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Create a variables file (optional)

Copy the example file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your desired values.

### 3. Plan the deployment

```bash
terraform plan
```

### 4. Apply the configuration

```bash
terraform apply
```

### 5. Destroy resources (when needed)

```bash
terraform destroy
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Name of the resource group | string | "rg-storage-example" | no |
| location | Azure region for resources | string | "East US" | no |
| storage_account_name | Name of the storage account (globally unique) | string | "stexample001" | no |
| account_tier | Storage account tier (Standard or Premium) | string | "Standard" | no |
| account_replication_type | Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS) | string | "LRS" | no |
| container_name | Name of the blob container | string | "data-container" | no |
| container_access_type | Access level (private, blob, or container) | string | "private" | no |
| enable_https_traffic_only | Enable HTTPS traffic only | bool | true | no |
| min_tls_version | Minimum TLS version | string | "TLS1_2" | no |
| tags | Tags to apply to resources | map(string) | See defaults | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Name of the resource group |
| storage_account_name | Name of the storage account |
| storage_account_id | ID of the storage account |
| primary_blob_endpoint | Primary blob endpoint URL |
| primary_access_key | Primary access key (sensitive) |
| container_name | Name of the blob container |
| container_id | ID of the blob container |

## Storage Account Naming Rules

- Must be between 3 and 24 characters
- Can contain only lowercase letters and numbers
- Must be globally unique across Azure

## Replication Types

- **LRS** (Locally Redundant Storage): 3 copies in a single datacenter
- **GRS** (Geo-Redundant Storage): 6 copies across two regions
- **RAGRS** (Read-Access Geo-Redundant Storage): GRS with read access to secondary region
- **ZRS** (Zone-Redundant Storage): 3 copies across availability zones
- **GZRS** (Geo-Zone-Redundant Storage): ZRS in primary + LRS in secondary region
- **RAGZRS** (Read-Access Geo-Zone-Redundant Storage): GZRS with read access to secondary

## Container Access Types

- **private**: No anonymous access (default, recommended)
- **blob**: Anonymous read access for blobs only
- **container**: Anonymous read access for containers and blobs

## Security Best Practices

This template implements several security best practices:

1. **HTTPS Only**: Enforces secure connections
2. **TLS 1.2 Minimum**: Uses modern encryption standards
3. **Network Rules**: Default deny with Azure Services bypass
4. **Soft Delete**: 7-day retention for accidental deletion recovery
5. **Versioning**: Blob versioning enabled for data protection
6. **No Public Access**: Nested items cannot be made public by default

## Customization

### Adding IP Whitelist

Uncomment and modify the `ip_rules` in the network_rules block:

```hcl
network_rules {
  default_action = "Deny"
  bypass         = ["AzureServices"]
  ip_rules       = ["203.0.113.0/24", "198.51.100.10"]
}
```

### Adding Virtual Network Rules

Add subnet IDs to allow access from specific VNets:

```hcl
network_rules {
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = [azurerm_subnet.example.id]
}
```

### Multiple Containers

To create multiple containers, use a `for_each` loop:

```hcl
variable "containers" {
  type = map(string)
  default = {
    "data"    = "private"
    "logs"    = "private"
    "backups" = "private"
  }
}

resource "azurerm_storage_container" "containers" {
  for_each              = var.containers
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = each.value
}
```

## Troubleshooting

### Storage Account Name Already Exists

Storage account names must be globally unique. Try a different name or add a random suffix:

```hcl
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

variable "storage_account_name" {
  default = "stexample${random_string.suffix.result}"
}
```

### Network Access Issues

If you're blocked by network rules, temporarily set `default_action = "Allow"` or add your IP to `ip_rules`.

## License

This template is provided as-is for educational and production use.

## Contributing

Feel free to submit issues or pull requests for improvements.