# How Does One Use This?

Please note that the master branch is generally *unstable*. If you are looking for something
"tested", please consume one of our [releases](https://github.com/pivotal-cf/terraforming-gcp/releases).

## What Does This Do?

You will get a booted ops-manager VM plus some networking, just the bare bones basically.

## Looking to setup a different IAAS

We have have other terraform templates to help you!

- [aws](https://github.com/pivotal-cf/terraforming-aws)
- [azure](https://github.com/pivotal-cf/terraforming-azure)

This list will be updated when more infrastructures come along.

## Prerequisites

Your system needs the `gcloud` cli, as well as `terraform`:

```bash
brew update
brew install Caskroom/cask/google-cloud-sdk
brew install terraform
```

## Notes

You will need a key file for your [service account](https://cloud.google.com/iam/docs/service-accounts)
to allow terraform to deploy resources. If you don't have one, you can create a service account and a key for it:

```bash
gcloud iam service-accounts create ACCOUNT_NAME --display-name "Some Account Name"
gcloud iam service-accounts keys create "terraform.key.json" --iam-account "ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding PROJECT_ID --member 'serviceAccount:ACCOUNT_NAME@PROJECT_ID.iam.gserviceaccount.com' --role 'roles/owner'
```

You will need to enable the following Google Cloud APIs:
- [Identity and Access Management](https://console.developers.google.com/apis/api/iam.googleapis.com)
- [Cloud Resource Manager](https://console.developers.google.com/apis/api/cloudresourcemanager.googleapis.com/)
- [Cloud DNS](https://console.developers.google.com/apis/api/dns/overview)
- [Cloud SQL API](https://console.developers.google.com/apis/api/sqladmin/overview)

### Var File

Copy the stub content below into a file called `terraform.tfvars` and put it in the root of this project.
These vars will be used when you run `terraform  apply`.
You should fill in the stub values with the correct content.

```hcl
env_name         = "some-environment-name"
project          = "your-gcp-project"
region           = "us-central1"
zones            = ["us-central1-a", "us-central1-b", "us-central1-c"]
dns_suffix       = "gcp.some-project.cf-app.com"
opsman_image_url = "https://storage.googleapis.com/ops-manager-us/pcf-gcp-2.0-build.264.tar.gz"
jumpbox          = "true"
pks              = "true"
buckets_location = "US"

ssl_cert = <<SSL_CERT
-----BEGIN CERTIFICATE-----
some cert
-----END CERTIFICATE-----
SSL_CERT

ssl_private_key = <<SSL_KEY
-----BEGIN RSA PRIVATE KEY-----
some cert private key
-----END RSA PRIVATE KEY-----
SSL_KEY

service_account_key = <<SERVICE_ACCOUNT_KEY
{
  "type": "service_account",
  "project_id": "your-gcp-project",
  "private_key_id": "another-gcp-private-key",
  "private_key": "-----BEGIN PRIVATE KEY-----another gcp private key-----END PRIVATE KEY-----\n",
  "client_email": "something@example.com",
  "client_id": "11111111111111",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://accounts.google.com/o/oauth2/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/"
}
SERVICE_ACCOUNT_KEY
```

### Var Details
- env\_name: **(required)** An arbitrary unique name for namespacing resources. Max 23 characters.
- project: **(required)** ID for your GCP project.
- region: **(required)** Region in which to create resources (e.g. us-central1)
- zones: **(required)** Zones in which to create resources. Must be within the given region. Currently you must specify exactly 3 Zones for this terraform configuration to work. (e.g. [us-central1-a, us-central1-b, us-central1-c])
- opsman\_image\_url **(required)** Source URL of the Ops Manager image you want to boot.
- service\_account\_key: **(required)** Contents of your service account key file generated using the `gcloud iam service-accounts keys create` command.
- dns\_suffix: **(required)** Domain to add environment subdomain to (e.g. foo.example.com)
- buckets\_location: **(optional)** Loction in which to create buckets. Defaults to US.
- ssl\_cert: **(optional)** SSL certificate for HTTP load balancer configuration. Required unless `ssl_ca_cert` is specified.
- ssl\_private\_key: **(optional)** Private key for above SSL certificate. Required unless `ssl_ca_cert` is specified.
- ssl\_ca\_cert: **(optional)** SSL CA certificate used to generate self-signed HTTP load balancer certificate. Required unless `ssl_cert` is specified.
- ssl\_ca\_private\_key: **(optional)** Private key for above SSL CA certificate. Required unless `ssl_cert` is specified.
- opsman\_storage\_bucket\_count: **(optional)** Google Storage Bucket for BOSH's Blobstore.
- create\_iam\_service\_account\_members: **(optional)** Create IAM Service Account project roles. Default to true.

## DNS Records
- pcf.*$env_name*.*$dns_suffix*: Points at the Ops Manager VM's public IP address.
- \*.sys.*$env_name*.*$dns_suffix*: Points at the HTTP/S load balancer in front of the Router.
- doppler.sys.*$env_name*.*$dns_suffix*: Points at the TCP load balancer in front of the Router. This address is used to send websocket traffic to the Doppler server.
- loggregator.sys.*$env_name*.*$dns_suffix*: Points at the TCP load balancer in front of the Router. This address is used to send websocket traffic to the Loggregator Trafficcontroller.
- \*.apps.*$env_name*.*$dns_suffix*: Points at the HTTP/S load balancer in front of the Router.
- \*.ws.*$env_name*.*$dns_suffix*: Points at the TCP load balancer in front of the Router. This address can be used for application websocket traffic.
- ssh.sys.*$env_name*.*$dns_suffix*: Points at the TCP load balancer in front of the Diego brain.
- tcp.*$env_name*.*$dns_suffix*: Points at the TCP load balancer in front of the TCP router.

## Isolation Segments (optional)
- isolation\_segment: **(optional)** When set to "true" creates HTTP load-balancer across 3 zones for isolation segments.
- iso\_seg\_ssl\_cert: **(optional)** SSL certificate for Iso Seg HTTP load balancer configuration. Required unless `iso_seg_ssl_ca_cert` is specified.
- iso\_seg\_ssl\_private\_key: **(optional)** Private key for above SSL certificate. Required unless `iso_seg_ssl_ca_cert` is specified.
- iso\_seg\_ssl\_ca\_cert: **(optional)** SSL CA certificate used to generate self-signed Iso Seg HTTP load balancer certificate. Required unless `iso_seg_ssl_cert` is specified.
- iso\_seg\_ssl\_ca\_private\_key: **(optional)** Private key for above SSL CA certificate. Required unless `iso_seg_ssl_cert` is specified.

## Cloud SQL Configuration (optional)
- external\_database: **(optional)** When set to "true", a cloud SQL instance will be deployed for the Ops Manager and PAS.

## Ops Manager (optional)
- opsman\_sql\_db\_host: **(optional)** The host the user can connect from. Can be an IP address. Changing this forces a new resource to be created.

## PAS (optional)
- pas\_sql\_db\_host: **(optional)** The host the user can connect from. Can be an IP address. Changing this forces a new resource to be created.

## PAS Cloud Controller's Google Cloud Storage Buckets (optional)
- create\_gcs\_buckets: **(optional)** When set to "false", buckets will not be created for PAS Cloud Controller. Defaults to "true".

## PKS (optional)
- pks: **(optional)** When set to "true" creates a tcp load-balancer for PKS api, dedicated subnets and allows access on Port `8443` to `masters` external IP address for `kubectl` access

## Internetless (optional)
- internetless: **(optional)** When set to "true", all traffic going outside the 10.* network is denied.

## Running

Note: please make sure you have created the `terraform.tfvars` file above as mentioned.

### Standing up environment

```bash
terraform init
terraform plan -out=plan
terraform apply plan
```

### Tearing down environment

```bash
terraform destroy
```

## Configuring Operations Manager

Once you've run terraform successfully you should find a new directory in your working path called `files` in there will be a file `opsman-gcp-config` which will describe how to configure the GCP tile in opsman using the outputs of this deployment.

# Then what?
## SSH into the jumpbox
A jumpbox can be created by setting jumpbox = "true" in the terraform.tfvars.  It will reside on the management network along side the ops manager / bosh director.  The default user will be ubuntu and the jumpbox will be configured into the DNS zone created for your environment.  The private key required is generated from `terraform output ops_manager_ssh_private_key > jumpbox.key`.  

```bash
terraform output ops_manager_ssh_private_key > /tmp/jumpbox.key
chmod 600 /tmp/jumpbox.key
ssh ubuntu@jumpbox.environment.example.com -i /tmp/jumpbox.key
```

You can use the jumpbox to save your home bandwidth when installing tiles to Ops Manager.  A collection of pcf tools from http://github.com/scottbri/pcftools are staged in ~/work/pcftools.  Also the 'om' Ops Manager CLI is installed in ~/bin.

To install the PKS tile for example, do the following:
- login to the jumpbox via the process above

```bash
cd ~/work
pcftools/pivnet-download.sh	# this will give you the command line syntax needed to download from PivNet
```
To get the above information:
- login to network.pivotal.io
- click your username in the top right --> Edit Profile
- record your LEGACY API TOKEN [DEPRECATED]
- return to the network.pivotal.io homepage and search for "pks"
- inside the Pivotal Container Service (PKS) page, click the "i" information image to the right of "pivotal-container-service-....pivotal"
- record the API Download URL (https://network.pivotal.io/api/...)
- record the File name (pivotal-container-service...pivotal)
- return to the Pivotal Container Service (PKS) page
- In the bottom right of the screen click on the Stem Cells version link
- Download the "light" stemcell appropriate for your IaaS (GCP)
- return to the command line and execute

```bash
# Download the PKS tile with this command.  It's about 4GB in size.
pcftools/pivnet-download.sh <paste API TOKEN> <API Download URL> <filename>

# when the download is complete, upload the file to Ops Manager
# this tool requires the om 
which om 	# to verify ~/bin/om is in your path
pcftools/upload-product.sh <FQDN of ops manager> <username> <password> <filename-just-downloaded>

# when the upload is complete, stage the tile on Ops Manager
# This command is user interactive.  Follow the prompts provided.
pcftools/stage-product.sh <FQDN of ops manager> <username> <password>
```

Now the PKS Tile should be visible in Ops Manager.  Refresh that page to see it and begin configuring it.

Once you're done configuring it, click on the link Missing Stemcell in the center of the tile.  Upload the stemcell you downloaded from PivNet.  (It should be small if you used the Lite version).


## Connecting BOSH CLI to the BOSH Director
You will need to log into Ops Manager to grab various credentials and information needed.  Also, you'll need to create an SSH tunnel through the jumpbox configured above to connect to the BOSH director over the internal IP.

- Login to Ops Manager
- Click on the BOSH Director Tile, and then on the Status Tab
- Record the Bosh Director IP Address <Bosh_Director_IP_Addr>
- Click on the Credentials Tab
- Record the username and password for the "Uaa Admin User Credentials"
- Click on your username in the top right of the screen, and then on Settings
- Click on Advanced [Settings] --> Download Root CA Cert
- Save into some file name of your choice <Root_CA_Cert_File>
- follow the below commands

```bash
# create a SOCKS5 proxy through the jumpbox referenced above
ssh -N -D 9999 ubuntu@jumpbox.environment.example.com -i jumpbox.key -f

# let the bosh cli know about the proxy
export BOSH_ALL_PROXY=socks5://localhost:9999

# alias the bosh director with the CA Cert captured above
bosh -e <Bosh_Director_IP_Addr> alias-env <short-name> --ca-cert <Root_CA_Cert_File>

# Log-in to the director with the Uaa credentials captured above
bosh -e <short-name> log-in 
# Email (): is the Uaa username (likely admin)
# Password (): is the Uaa Credentials password long string

# Verify you're logged in
bosh -e <short-name> env
bosh -e <short-name> events
bosh -e <short-name> deployments

