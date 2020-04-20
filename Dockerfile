FROM rubylang/ruby:2.6.6-bionic

MAINTAINER hana-da <hana-da@users.noreply.github.com>
ENV APP_HOME=/mini_blog

ENV PATH=$APP_HOME/bin:$PATH \
    BUNDLE_DISABLE_VERSION_CHECK=true \
    BUNDLER_VERSION=2.0.2

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
    && n stable \
    && npm install -g yarn \
    && apt-get purge -y $forWebpacker \
    # clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    # install bundler
    && gem install bundler --version ${BUNDLER_VERSION}
