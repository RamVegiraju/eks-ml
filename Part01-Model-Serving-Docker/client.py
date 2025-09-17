import requests

"""
Curl version:

curl -X POST http://127.0.0.1:8000/translate \ -H "Content-Type: application/json" \ -d '{"text":"Hello, how are you?"}' convert this to python requests library
"""

# expose path defined in FastAPI app
url = "http://127.0.0.1:8000/translate"
payload = {"text": "Hello, how are you?"}

response = requests.post(url, json=payload)

print("Status:", response.status_code)
print("Response:", response.json())