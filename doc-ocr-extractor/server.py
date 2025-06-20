import os
from flask import Flask, request, jsonify
import pdfplumber
import pytesseract
from pdf2image import convert_from_path
from PIL import Image

app = Flask(__name__)
DOC_PATH = "/app/documentos"
os.makedirs(DOC_PATH, exist_ok=True)

@app.route("/ocr", methods=["POST"])
def ocr():
    if 'file' not in request.files:
        return jsonify({"error": "No file provided"}), 400

    file = request.files['file']
    filename = file.filename or "uploaded.pdf"
    filepath = os.path.join(DOC_PATH, filename)
    file.save(filepath)

    extracted_text = ""

    try:
        with pdfplumber.open(filepath) as pdf:
            for page in pdf.pages:
                text = page.extract_text()
                if text:
                    extracted_text += text + "\n"

        if not extracted_text.strip():
            images = convert_from_path(filepath)
            for img in images:
                extracted_text += pytesseract.image_to_string(img) + "\n"

    except Exception as e:
        return jsonify({"error": f"Failed to process file: {str(e)}"}), 500

    return jsonify({"text": extracted_text.strip()}), 200

# 🔽 BLOQUE QUE FALTABA
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)