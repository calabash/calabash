LOCAL_PATH := $(call my-dir)

#
# Compiled without Position Independent Code (PIE)
# As required for Androids < 4.1 (<16).
#
include $(CLEAR_VARS)
LOCAL_MODULE := calmd5
LOCAL_SRC_FILES := main.c md5.c

include $(BUILD_EXECUTABLE)

#
## Moden version, build with PIE, as required for Android 4.1+ (16+).
#
include $(CLEAR_VARS)
LOCAL_MODULE := calmd5-pie
LOCAL_SRC_FILES := main.c md5.c
LOCAL_LDFLAGS := -fPIE -pie

include $(BUILD_EXECUTABLE)
