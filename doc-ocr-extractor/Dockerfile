FROM python:3.10-slim

ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    poppler-utils \
    libtesseract-dev \
    libreoffice \
    libgl1 \
    build-essential \
    ghostscript \
    libmagic-dev \
    curl \
    && apt-get clean

RUN pip install --no-cache-dir \
    pytesseract \
    pdfplumber \
    pdf2image \
    Pillow \
    unstructured[all-pdf] \
    python-docx \
    lxml \
    flask

RUN mkdir -p /app/documentos

WORKDIR /app
COPY server.py /app/server.py

CMD ["python", "server.py"]