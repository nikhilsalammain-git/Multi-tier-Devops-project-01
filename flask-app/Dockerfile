FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt ./

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& pip install --no-cache-dir --upgrade -r requirements.txt


COPY . .

EXPOSE 4000

CMD ["flask", "run", "--host=0.0.0.0", "--port=4000"]
