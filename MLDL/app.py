# Import necessary packages.
from flask import Flask, request, jsonify, send_file
from urllib.parse import unquote
from PIL import Image
from io import BytesIO
import requests
import os
import re
import google.generativeai as genai
from openai import OpenAI

# Create a Flask application.
app = Flask(__name__)

# Set server URL and API key.
SERVER_URL = "SERVER_URL"
GEMINI_API_KEY = "GEMINI_API_KEY"
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(model_name='gemini-pro')

# Initialize OpenAI client.
client = OpenAI(
    api_key = "OPENAI_API_KEY"
)

# Handle requests to the '/' endpoint with the POST method.
@app.route('/', methods=['POST'])
def process_audio():
    # Get request data.
    request_data = request.json
    if 'link' not in request_data:
        return "Invalid request parameters", 400
    lyrics = request_data['lyrics']
    link = request_data['link']
    pattern = r'/([^/]+)\.mp3$'
    match = re.search(pattern, link)
    code = match.group(1)  # The extracted identifier from the link
    code = unquote(code)  # Decode any URL-encoded characters in the code

    if not link or not code:
        return "Invalid request parameters", 400
    audio_file = download_audio(link, code)
    if not audio_file:
        return "Failed to download audio file", 500
    
    # Call functions to generate scene and image.
    scene = generate_scene(lyrics, code)
    image_url = generate_image(scene, code)

    if scene and image_url :
        if image_url == -1 : 
            response_data = {'url': -1, 'text':-1}
            return jsonify(response_data)
        response_data = {'url': f"http://{SERVER_URL}/{image_url}", 'text': scene}
        return jsonify(response_data)
    else:
        return "Failed to generate image", 500

# Function to download audio file.
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

# Function to generate scene description.
def generate_scene(lyrics, code):
    while True:
        try:
            question = "Imagine a scene that suits the following lyrics and describe it briefly in about 5 sentences in Korean."
            response = model.generate_content([
                {"text": question},
                {"text": lyrics}
            ])
            print("Response Text:", response.candidates[0].content.parts)
            text = response.text
            return text
        except Exception as e:
            print("An error occurred:", str(e))

# Function to generate image.
def generate_image(scene, code):
        try:
            response = client.images.generate(
                model="dall-e-3",
                prompt=scene,
                n=1,
                size="1024x1024"
            )
            image_url = response.data[0].url
            image_data = requests.get(image_url).content
            with open(os.path.join('images', f'{code}.jpeg'), 'wb') as handler:
                handler.write(image_data)
            return os.path.join('images', f'{code}.jpeg')
        except Exception as e:
            print("An error occurred:", str(e))
            return -1

# Send the requested image file to the client.
@app.route('/images/<string:imageName>', methods=['GET'])
def image(imageName):
    return send_file("images/"+imageName)

# Run the Flask application if this script is executed as the main program.
if __name__ == '__main__':
    app.run(debug=True)
