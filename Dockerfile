FROM crystallang/crystal:0.23.0

# Install required packages
RUN apt-get update && apt-get install -y ffmpeg

# Add the app and build it
WORKDIR /app/
ADD . /app
ARG APP_ENV=production
RUN shards build --production

# Run the app
CMD "bin/server"
