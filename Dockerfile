# Use the official Dart image as a base
FROM dart:stable AS build

WORKDIR /app

# Copy pubspec files and install dependencies
COPY pubspec.* ./
RUN dart pub get

# Copy the rest of the application
COPY . ./

# Build the application (if using Flutter, adjust accordingly)
# For a Dart server, you might use: RUN dart compile exe bin/server.dart -o bin/server
# For Flutter web: RUN flutter build web

# Expose the port your app runs on (adjust as needed)
EXPOSE 8080

# Start the app (adjust entrypoint as needed)
CMD ["dart", "run", "lib/main.dart"]
