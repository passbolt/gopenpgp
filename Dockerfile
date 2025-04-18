FROM golang:1.23

ENV ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_SDK_ROOT="/usr/local/android-sdk" \
    ANDROID_VERSION=34 \
    ANDROID_BUILD_TOOLS_VERSION="36.0.0" \
    ANDROID_SDK_TOOLS_VERSION="13114758" \
    ANDROID_NDK_VERSION=29.0.13113456

# install system dependencies
RUN apt-get update && \
    apt-get install -y wget unzip openjdk-17-jdk

# setup android home path for moving the downloaded sdk into it
RUN install -d $ANDROID_HOME

# download and extract android sdk tools
RUN wget --quiet --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip \
    && unzip $ANDROID_HOME/cmdline-tools.zip -d $ANDROID_HOME \
    && rm $ANDROID_HOME/cmdline-tools.zip \
    && export PATH=$PATH:${ANDROID_HOME}/cmdline-tools/bin \
    && yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true \
    && sdkmanager --sdk_root=${ANDROID_HOME} --update \
    && sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    && sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_VERSION}" \
    && sdkmanager --sdk_root=${ANDROID_HOME} "ndk;${ANDROID_NDK_VERSION}"

# install gomobile
RUN go install golang.org/x/mobile/cmd/gomobile@latest && \
    $(go env GOPATH)/bin/gomobile init
ENV PATH=$GOPATH/bin:$PATH

WORKDIR /gopenpgp
