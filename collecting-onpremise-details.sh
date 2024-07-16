#!/bin/bash

# Function to print a decorative separator
print_separator() {
  echo "======================================================================================"
}

# Function to print a stage header
print_stage() {
  echo -e "\n\e[1;34m$1\e[0m"
}


read -p "Artifactory URL? " ARTIFACTORY_URL
read -p "Username: " USERNAME
read -sp "Password: " PASSWORD

echo
# Make a curl request to the Artifactory API to get the version information
response=$(curl -u "$USERNAME:$PASSWORD" -X GET "$ARTIFACTORY_URL/api/system/version" 2>/dev/null)

# Check if the response is not empty
if [ -z "$response" ]; then
  echo "Failed to get version information from Artifactory."
  exit 1
fi

filtered_response=$(echo "$response" | jq 'del(.addons)')
# Output the version information in a neat JSON format
echo "$filtered_response" | jq .
print_separator

echo "*** List of plugins associated/utilised in the self-hosted instance at the moment ***"
DIRECTORY_PATH=/home/yuvarajanj/artifactory-pro-7.84.15/var/etc/artifactory/plugins

# Check if the directory exists
if [ ! -d "$DIRECTORY_PATH" ]; then
  echo "Directory not found: $DIRECTORY_PATH"
  exit 1
fi

# Change to the given directory
cd "$DIRECTORY_PATH"

# List all files in a neat format
ls -l --color=auto
print_separator

# Make a curl request to the Artifactory API to get the storage summary
response=$(curl -s -u "$USERNAME:$PASSWORD" "$ARTIFACTORY_URL/api/storageinfo")

# Check if the curl request was successful
if [ $? -ne 0 ]; then
  echo "Failed to connect to Artifactory."
  exit 1
fi

# Check if the response is not empty
if [ -z "$response" ]; then
  echo "Failed to get storage summary from Artifactory."
  exit 1
fi

filtered_response=$(echo "$response" | jq 'del(.repositoriesSummaryList)')
# Output the storage summary in a neat JSON format
echo "$filtered_response" | jq .
print_separator

XML_FILE=/home/yuvarajanj/artifactory-pro-7.84.15/var/etc/artifactory/artifactory.config.latest.xml

# Check if the XML file exists
if [ ! -f "$XML_FILE" ]; then
  echo "File not found: $XML_FILE"
  exit 1
fi

# Parse the XML file to get the value of dockerReverseProxyMethod
#dockerReverseProxyMethod=$(xmllint --xpath 'string(//dockerReverseProxyMethod)' "$XML_FILE")
dockerReverseProxyMethod=$(cat "$XML_FILE" | grep -oP '(?<=<dockerReverseProxyMethod>).*?(?=</dockerReverseProxyMethod>)' | sed 's/^ *//;s/ *$//')

# Check if the dockerReverseProxyMethod tag was found
if [ -z "$dockerReverseProxyMethod" ]; then
  echo "dockerReverseProxyMethod tag not found in the XML file."
  exit 1
fi

# Output the value of dockerReverseProxyMethod
echo "dockerReverseProxyMethod: $dockerReverseProxyMethod"
