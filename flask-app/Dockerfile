FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt ./

RUN pip install -r requirements.txt
RUN pip install --upgrade "msgpack>=1.2.1" "setuptools>=78.1.1"

COPY . .

EXPOSE 4000

CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]
