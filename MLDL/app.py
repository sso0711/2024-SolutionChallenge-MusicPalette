# Import necessary libraries for web server, URL processing, HTTP requests, filesystem operations, and regular expressions
from flask import Flask, request, jsonify, send_file
from urllib.parse import unquote
import requests
import os
import subprocess
import re

# Define the server URL where the service is accessible
SERVER_URL = "SERVER_URL"

# Initialize the Flask application
app = Flask(__name__)

# Define a route for processing POST requests at the root URL
@app.route('/', methods=['POST'])
def process_audio():
    # Extract JSON data from the incoming request
    request_data = request.json
    # Ensure the request contains a 'link' field; if not, return an error
    if 'link' not in request_data:
        return "Invalid request parameters", 400
    
    # Extract 'lyrics' and 'link' from the request data
    lyrics = request_data['lyrics']
    link = request_data['link']
    # Regular expression to extract a specific part from the link (e.g., a code or identifier)
    pattern = r'/([^/]+)\.mp3$'
    # Use regex to find matches in the link, aiming to extract a unique code for the audio file
    match = re.search(pattern, link)
    code = match.group(1)  # The extracted identifier from the link
    code = unquote(code)  # Decode any URL-encoded characters in the code

    # Validate the presence of 'link' and 'code' to proceed
    if not link or not code:
        return "Invalid request parameters", 400

    # Download the audio file using the provided URL and extracted code
    audio_file_name = download_audio(link, code)

    # If downloading fails, return an error response
    if not audio_file_name:
        return "Failed to download audio file", 500

    # [Placeholder] This section is intended for calling a generative AI model or script to generate an image based on the audio.
    # Actual image generation logic (e.g., calling a separate script or service) would go here.
    # generate_image(audio_file_name, code)

    # Construct the path to the potentially generated image and check if it exists
    generated_image_path = os.path.join('images', f'{code}.jpeg')
    if os.path.exists(generated_image_path):
        # If the image exists, construct its URL for access over the web
        image_url = f"http://{SERVER_URL}/images/{code}.jpeg"
        # Read additional text associated with the image, if available
        with open(os.path.join('images', f'{code}.txt'), 'r') as file:
          text = file.read()
        # Return the image URL and any associated text as JSON
        response_data = {'url': image_url, 'text': text}
        return jsonify(response_data)
    else:
        # If image generation failed, return an error response
        return "Failed to generate image", 500

# Define a function to download an audio file given its URL and a unique code
def download_audio(url, code):
    try:
        # Attempt to download the file from the given URL
        response = requests.get(url)
        if response.status_code == 200:
            # If download is successful, construct the file name and save it
            file_name = f"{code}.mp3"
            audio_folder = 'music'
            # Ensure the target directory exists
            if not os.path.exists(audio_folder):
                os.makedirs(audio_folder)
            # Save the downloaded content to a file
            file_path = os.path.join(audio_folder, file_name)
            with open(file_path, 'wb') as f:
                f.write(response.content)
            return file_name
        else:
            return None
    except Exception as e:
        print("Error downloading audio:", e)
        return None

# Placeholder for a generative AI image generation function
# This would execute an external script or service, using the downloaded audio as input to generate an image.
def generate_image(audio_file_name, code):
    try:
        subprocess.run(['node', 'test.js', os.path.join('music', audio_file_name), str(code)])
    except Exception as e:
        print("Error generating image:", e)

# Define a route to serve image files from the 'images' directory
@app.route('/images/<string:imageName>')
def image(imageName):
    # Send the requested image file to the client
    return send_file("images/"+imageName)

# Run the Flask application if this script is executed as the main program
if __name__ == '__main__':
    app.run(debug=True)
