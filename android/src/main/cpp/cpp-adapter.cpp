#include <jni.h>
#include "alarmkitOnLoad.hpp"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void*) {
  return margelo::nitro::alarmkit::initialize(vm);
}
