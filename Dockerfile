FROM ghcr.io/gleam-lang/gleam:v1.5.1-erlang-alpine

# Add LiteFS binary, to replicate the SQLite database.
# COPY --from=flyio/litefs:0.5 /usr/local/bin/litefs /usr/local/bin/litefs

# Add project code
COPY . /build/

# Compile the Gleam application
RUN cd /build \
  && apk add bash curl fuse3 ca-certificates sqlite gcc build-base \
  && gleam export erlang-shipment \
  && mv build/erlang-shipment /app \
  && rm -r /build \
  && apk del gcc build-base \
  && addgroup -S webuser \
  && adduser -S webuser -G webuser \
  && chown -R webuser /app

# COPY litefs.yml /etc/litefs.yml

# install dbmate for migrations
RUN sudo curl -fsSL -o /usr/local/bin/dbmate https://github.com/amacneil/dbmate/releases/latest/download/dbmate-linux-amd64
RUN sudo chmod +x /usr/local/bin/dbmate

# Run the application
USER webuser
WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]

# ENTRYPOINT ["litefs", "mount"]