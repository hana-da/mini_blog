FROM rubylang/ruby:2.6.6-bionic

MAINTAINER hana-da <hana-da@users.noreply.github.com>
ENV APP_HOME=/mini_blog

ENV PATH=$APP_HOME/bin:$PATH \
    BUNDLE_DISABLE_VERSION_CHECK=true \
    BUNDLER_VERSION=2.0.2 \
    NODE_VERSION=v10.15.3 \
    YARN_VERSION=v1.16.0

WORKDIR $APP_HOME

RUN set -ex \
    && forRubyGems=' \
        # for sassc
        g++ \ 
        # for pg
        libpq-dev \
      ' \
    && forWebpacker=' \
        nodejs \
        npm \
        curl \
      ' \
    && apt-get update \
    && apt-get install -y $forRubyGems $forWebpacker \
    && npm install -g n \
    # install node and yarn via n
    && n ${NODE_VERSION} \
    && npm install -g yarn@${YARN_VERSION} \
    && apt-get purge -y $forWebpacker

RUN set -ex \
    && forDevelopmentAndDebugging=' \
        less \
        vim \
      ' \
    && apt-get install -y $forDevelopmentAndDebugging \
    # clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    # install bundler
    && gem install bundler --version ${BUNDLER_VERSION}
