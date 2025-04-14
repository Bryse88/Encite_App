import requests
import os

# Generate JWT
APPLE_MAPS_JWT_KEY=eyJhbGciOiJFUzI1NiIsImtpZCI6IlQ5UFJKSjJONjIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJYQ1M4NTNYTUQ0IiwiaWF0IjoxNzQxMjM0MTgxLCJleHAiOjE3NDEyMzc3ODF9.gYUp5G7EdxCLbvyl8PXI3AcmcNPYWs_n39YUatnm5tY4vhX04PBkjOQfV5YWcu7bnKGpl_m4fKSEG9hCAQLQfw
# APPLE_MAPS_JWT = os.getenv("APPLE_MAPS_JWT_KEY")
APPLE_MAPS_JWT_KEY = eyJhbGciOiJFUzI1NiIsImtpZCI6IlQ5UFJKSjJONjIiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJYQ1M4NTNYTUQ0IiwiaWF0IjoxNzQxMjM0MTgxLCJleHAiOjE3NDEyMzc3ODF9.gYUp5G7EdxCLbvyl8PXI3AcmcNPYWs_n39YUatnm5tY4vhX04PBkjOQfV5YWcu7bnKGpl_m4fKSEG9hCAQLQfw

# Define start & end locations
start_lat, start_lng = 43.0731, -89.4012
end_lat, end_lng = 43.0766, -89.4125

# API request
url = f"https://maps-api.apple.com/v1/directions?origin={start_lat},{start_lng}&destination={end_lat},{end_lng}&transportType=automobile"
headers = {
    "Authorization": f"Bearer {APPLE_MAPS_JWT}"
}

response = requests.get(url, headers=headers)

# Print results
if response.status_code == 200:
    print(response.json())  # ✅ Success!
else:
    print(f"Error {response.status_code}: {response.text}")
