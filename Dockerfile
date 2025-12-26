# 1️⃣ Base image
FROM python:3.9-slim

# 2️⃣ Set working directory
WORKDIR /app

# 3️⃣ Copy dependencies
COPY requirements.txt .

# 4️⃣ Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 5️⃣ Copy application code
COPY app.py .

# 6️⃣ Expose app port
EXPOSE 8001

# 7️⃣ Run the application
CMD ["python", "app.py"]
