ENGINE_DIR=~/work/engine_build/engine
EMBEDDING_DIR=$ENGINE_DIR/src/flutter/shell/platform/ohos/flutter_embedding
PROJECT_DIR=$(pwd)

buildType=debug
ENGINE_OUT_DIR=$ENGINE_DIR/src/out/ohos_debug_unopt_arm64

if [ ! -d $EMBEDDING_DIR/flutter/libs/arm64-v8a ]; then
    mkdir -p $EMBEDDING_DIR/flutter/libs/arm64-v8a
fi

cd $EMBEDDING_DIR
cp $ENGINE_OUT_DIR/libflutter.so $EMBEDDING_DIR/flutter/libs/arm64-v8a/
./hvigorw --mode module -p module=flutter@default -p product=default -p buildMode=$buildType assembleHar --no-daemon
cp $EMBEDDING_DIR/flutter/build/default/outputs/default/flutter.har $ENGINE_OUT_DIR/

cd $PROJECT_DIR
flutter run -d $(hdc list targets) --local-engine=$ENGINE_OUT_DIR --$buildType 2>&1 | tee build.log

# hdc hilog 2>&1 | tee hilog.log