# Structurizr "local" server preloaded with this C4 model.
# Build context: the folder containing workspace.dsl (your design/ folder).
#
# The model is baked in so the image runs standalone (docker run -p 8080:8080 <image>).
# For live editing, run.sh bind-mounts the folder over this path so edits to workspace.dsl
# show up on a browser refresh.
FROM structurizr/structurizr:latest

WORKDIR /usr/local/structurizr

COPY workspace.dsl ./
COPY code ./code

EXPOSE 8080

# Base image ENTRYPOINT is `java -jar structurizr.war`; "local" serves the on-disk
# workspace in WORKDIR at http://localhost:8080.
CMD ["local"]
