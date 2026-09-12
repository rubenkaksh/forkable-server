# Production image for Serverpod 4 (serverpod build cli pattern per plan §32).
# The server package uses dart build cli which produces a bundle with native assets.
FROM dart:3.13 AS build
WORKDIR /app

# Copy pubspec resolution artifacts first for layer caching
COPY pubspec.yaml server_base_server/pubspec.yaml ./
RUN cd server_base_server && dart pub get

# Copy everything needed to build the server
COPY server_base_server/ server_base_server/
RUN dart pub get --offline && \
    dart build cli -o build bin/main.dart

# Minimal runtime image
FROM dart:3.13
WORKDIR /app
COPY --from=build /app/server_base_server/build/ /app/server_base_server/build/
COPY server_base_server/config/ /app/server_base_server/config/
EXPOSE 8080 8081 8082
ENTRYPOINT ["dart", "server_base_server/build/bin/main.dart"]
