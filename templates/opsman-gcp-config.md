# Operations Manager GCP Tile Config

## Google Config

Project ID: ${project}
Default Deployment Tag: ${deployment_tag}
AuthJSON: __paste in contents of `opsman-gcp-account.json`__

## Director Config

NTP Servers: metadata.google.internal
[x] Enable VM Resurrector Plugin
[x] Enable Post Deploy Scripts
Blobstore Location: Internal
Database Location: Internal

## Create Availability Zones

${azs}

## Create Networks

### Management Subnet:

Name: ${subnet_mgmt_name}
Google Network Name: ${subnet_mgmt_google_name}
CIDR: ${subnet_mgmt_cidr}
Reserved IP Ranges: ${subnet_mgmt_reserved}
DNS: 169.254.169.254
Gateway: ${subnet_mgmt_gateway}
Availability Zones: ${azs}

### PAS Subnet:

Name: ${subnet_pas_name}
Google Network Name: ${subnet_pas_google_name}
CIDR: ${subnet_pas_cidr}
Reserved IP Ranges: ${subnet_pas_reserved}
DNS: 169.254.169.254
Gateway: ${subnet_pas_gateway}
Availability Zones: ${azs}

### PAS Services Subnet:

Name: ${subnet_pas_svc_name}
Google Network Name: ${subnet_pas_svc_google_name}
CIDR: ${subnet_pas_svc_cidr}
Reserved IP Ranges: ${subnet_pas_svc_reserved}
DNS: 169.254.169.254
Gateway: ${subnet_pas_svc_gateway}
Availability Zones: ${azs}

### PKS Subnet:

Name: ${subnet_pks_name}
Google Network Name: ${subnet_pks_google_name}
CIDR: ${subnet_pks_cidr}
Reserved IP Ranges: ${subnet_pks_reserved}
DNS: 169.254.169.254
Gateway: ${subnet_pks_gateway}
Availability Zones: ${azs}

### PKS Services Subnet:

Name: ${subnet_pks_svc_name}
Google Network Name: ${subnet_pks_svc_google_name}
CIDR: ${subnet_pks_svc_cidr}
Reserved IP Ranges: ${subnet_pks_svc_reserved}
DNS: 169.254.169.254
Gateway: ${subnet_pks_svc_gateway}
Availability Zones: ${azs}

## Assing AZs and Networks

Singleton Availability Zone: ${singleton_az}
Network: ${subnet_mgmt_name}

## Security

Download the CA cert from `Operations Manager -> Settings -> Advanced` and paste the contents into here.

## Resource Config

Ensure all resources are "internet connected"