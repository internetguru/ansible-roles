#!/bin/bash

# Ask for api key only once, store it into tmp
api_key=/tmp/ansible_galaxy_api_key
if [[ ! -f "${api_key}" ]]; then
    read -rsp 'Enter API key: ' api_key_value
    echo "${api_key_value}" > "${api_key}"
    chmod 600 "${api_key}"  # Secure the file
    unset api_key_value
else
    echo "Using API key from ${api_key}"
fi

# Loop through each collection directory
for collection_dir in */ ; do
    # Change to the collection directory
    cd "${collection_dir}" \
      || exit 1
    # Build the collection
    ansible-galaxy collection build
    # Extract the collection name and version from galaxy.yml
    namespace=$(grep 'namespace:' galaxy.yml | awk '{print $2}')
    name=$(grep 'name:' galaxy.yml | awk '{print $2}')
    version=$(grep 'version:' galaxy.yml | awk '{print $2}')
    # Publish the collection
    ansible-galaxy collection publish "${namespace}-${name}-${version}.tar.gz" --api-key "$(cat "${api_key}")"
    # Clean up the built collection tarball
    rm -f "${namespace}-${name}-${version}.tar.gz"
    # Change back to the collections directory
    cd ..
done
echo "All collections have been built, published, and cleaned up."
