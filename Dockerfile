#
# GitLab CI: Android
#
# https://hub.docker.com/r/showcheap/gitlab-ci-android/
# https://gitlab.com/hardysim/android-ci
#

FROM openjdk:11-jdk
LABEL key="Bin Li <bin.lee.1980@gmail.com>"

ENV SDK_URL "https://dl.google.com/android/repository/sdk-tools-linux-7583922.zip"
ENV VERSION_BUILD_TOOLS "30.0.3"
ENV VERSION_TARGET_SDK "30"

# Prepare System
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get --quiet update --yes && \
    apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 && \
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
RUN yes | sdkmanager --licenses || true
    sdkmanager "platform-tools" > /dev/null && \
    sdkmanager "platforms;android-${VERSION_TARGET_SDK}" > /dev/null && \
    sdkmanager "build-tools;${VERSION_BUILD_TOOLS}" > /dev/null 

# Download Gradle
# ENV GRADLE_VERSION 4.4
# ADD https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip /gradle.zip
# RUN unzip -q /gradle.zip -d /opt/gradle/ && \
#     rm -v /gradle.zip
# ENV GRADLE_HOME /opt/gradle

# ENV PATH "${PATH}:/opt/gradle/gradle-${GRADLE_VERSION}/bin"
