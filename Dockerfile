#
# GitLab CI: Android
#
# https://hub.docker.com/r/showcheap/gitlab-ci-android/
# https://gitlab.com/hardysim/android-ci
#

FROM ubuntu:18.04
LABEL key="Bin Li <bin.lee.1980@gmail.com>"

ENV SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV VERSION_BUILD_TOOLS "28.0.2"
ENV VERSION_TARGET_SDK "28"

# Prepare System
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends curl html2text openjdk-8-jdk libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 unzip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

# GitLab injects the username as ENV-variable which will crash a gradle-build.
# Workaround by adding unicode-support.
# See
# https://github.com/gradle/gradle/issues/3117#issuecomment-336192694
# https://github.com/tianon/docker-brew-debian/issues/45
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# Download SDK
ADD ${SDK_URL} /tools.zip
RUN unzip -q /tools.zip -d /sdk && \
    rm -v /tools.zip

# Configure PATH
ENV ANDROID_HOME "/sdk"
ENV PATH "${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"

# Accept License
RUN mkdir -p $ANDROID_HOME/licenses/ && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license && \
    echo "d56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-preview-license

# Install SDK Package
RUN sdkmanager "platform-tools" > /dev/null && \
    sdkmanager "platforms;android-${VERSION_TARGET_SDK}" > /dev/null && \
    sdkmanager "build-tools;${VERSION_BUILD_TOOLS}" > /dev/null && \
    sdkmanager "extras;android;m2repository" > /dev/null && \
    sdkmanager "extras;google;m2repository" > /dev/null && \
    sdkmanager "extras;google;google_play_services" > /dev/null && \
    sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" > /dev/null && \
    sdkmanager "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" > /dev/null

# Download Gradle
# ENV GRADLE_VERSION 4.4
# ADD https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip /gradle.zip
# RUN unzip -q /gradle.zip -d /opt/gradle/ && \
#     rm -v /gradle.zip
# ENV GRADLE_HOME /opt/gradle

# ENV PATH "${PATH}:/opt/gradle/gradle-${GRADLE_VERSION}/bin"
