# Production Dockerfile for Fly.io deployment
# Based on Phoenix 1.8 release template
#
# Uses official elixir images (same as devcontainer) for better compatibility

ARG NODE_IMAGE="node:22-slim"
ARG BUILDER_IMAGE="elixir:1.19-otp-27-slim"
ARG RUNNER_IMAGE="debian:bookworm-slim"

# Get Node.js from official image (avoids curl | bash supply chain risk)
FROM ${NODE_IMAGE} as node

FROM ${BUILDER_IMAGE} as builder

# Copy Node.js from official image (copy node_modules first, then create symlinks)
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /usr/local/bin/node /usr/local/bin/node
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="prod"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# Copy compile-time config files
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

# Build assets
COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci

COPY priv priv
COPY assets assets
COPY lib lib

# Compile assets
RUN npm --prefix ./assets run build
RUN mix assets.deploy

# Compile the release
COPY config/runtime.exs config/
RUN mix compile

# Build release
COPY rel rel
RUN mix release

# Runner stage
FROM ${RUNNER_IMAGE}

RUN apt-get update -y && \
    apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# Set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/reify ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init system such as tini via `CMD ["/tini", "--", "bin/server"]`
CMD ["/app/bin/server"]
