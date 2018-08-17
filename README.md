# android-ci

```yml
image: registry.gitlab.com/hardysim/android-ci:latest

cache:
  paths:
  - .gradle/wrapper
  - .gradle/caches
  - .android/build-cache/

before_script:
  # move gradle-cache and android-build-cache to folders inside the build-folder so it can be used by the GitLab CI cache
  # http://stackoverflow.com/a/36050711/2170109
  # https://developer.android.com/studio/build/build-cache.html
  - export GRADLE_USER_HOME=.gradle
  - export ANDROID_SDK_HOME=$CI_PROJECT_DIR
  # make gradle executable
  - chmod +x ./gradlew

build:
  stage: build
  script:
     - ./gradlew assemble

test:
  stage: test
  script:
     - ./gradlew check

```