# ================================
# Build image
# ================================
FROM pirateguillermo/swift:latest as mirror-build

WORKDIR /opt/Mirror-Package

COPY ./Package.* ./
RUN swift package resolve

# Copy entire repo into container
COPY . .

RUN swift build -c release

RUN install -C "$(swift build --package-path /opt/Mirror-Package -c release --show-bin-path)"/Mirror-Package /usr/local/bin

RUN mv /usr/local/bin/Mirror-Package /usr/local/bin/mirror

# ==============================
# Tool image
# ==============================
FROM pirateguillermo/swift:latest

COPY --from=mirror-build /usr/local/bin/mirror /usr/local/bin/mirror

LABEL maintainer="sbeitzel@pobox.com"