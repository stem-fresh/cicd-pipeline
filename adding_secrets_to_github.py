import requests
import json
from base64 import b64encode,b64decode
import nacl.encoding
import nacl.public

# Set your GitHub token and repository details
GITHUB_TOKEN = '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'
REPO_OWNER = 'stem-fresh'
REPO_NAME = 'cicd-pipeline'

# GitHub API base URL
API_URL = f'https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/actions/secrets'

# Headers for the API request
HEADERS = {
    'Authorization': f'token {GITHUB_TOKEN}',
    'Accept': 'application/vnd.github.v3+json',
}

# Function to encrypt and add secret to GitHub
def add_secret(secret_name, secret_value, public_key, key_id):
    encrypted_value = encrypt_value(secret_value, public_key)
    url = f'{API_URL}/{secret_name}'
    data = {
        'encrypted_value': encrypted_value,
        'key_id': key_id
    }
    response = requests.put(url, headers=HEADERS, data=json.dumps(data))
    
    if response.status_code == 201:
        print(f'Successfully added secret: {secret_name}')
    else:
        print(f'Failed to add secret: {secret_name}. Status code: {response.status_code}, Response: {response.text}')

# Function to encrypt the secret value using the public key from GitHub
def encrypt_value(secret_value, public_key):
    public_key_bytes = b64decode(public_key)
    
    # Use nacl library to load the public key and encrypt the secret
    public_key = nacl.public.PublicKey(public_key_bytes, nacl.encoding.RawEncoder())
    sealed_box = nacl.public.SealedBox(public_key)
    
    encrypted = sealed_box.encrypt(secret_value.encode('utf-8'))
    
    return b64encode(encrypted).decode('utf-8')

# Get the public key of the repository to encrypt secrets
def get_public_key():
    url = f'{API_URL}/public-key'
    response = requests.get(url, headers=HEADERS)
    
    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f'Failed to get public key: {response.text}')

# Function to read environment variables from a file and handle JSON-like strings
def read_env_file(file_path):
    env_vars = {}
    with open(file_path) as f:
        content = f.read().strip()
        # Check if the content is valid JSON, in case it's a dictionary
        if content.startswith("SA_secrets"):
            key, json_value = content.split('=', 1)
            env_vars[key] = json_value.strip()
        else:
            for line in content.splitlines():
                line = line.strip()
                if line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars

# Main function to add all environment variables
def main():
    public_key_info = get_public_key()
    public_key = public_key_info['key']
    key_id = public_key_info['key_id']
    
    # Read environment variables from the file
    env_vars = read_env_file('env_vars.txt')
    
    for secret_name, secret_value in env_vars.items():
        add_secret(secret_name, secret_value, public_key, key_id)

if __name__ == "__main__":
    main()
