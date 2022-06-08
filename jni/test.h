/* * test.h
 *
 *  Created on: Jun 19, 2015
 *      Author: root
 */

#ifndef TEST_H_
#define TEST_H_




#ifdef standalone

#ifdef __cplusplus
#include <gtest/gtest.h>
#define BTFT(test_case_name, test_name)\
extern "C" int test_name();\
TEST(test_case_name,test_name)\
{\
	/*printf("start test_name\n");*/\
	int result = test_name();\
	ASSERT_EQ(result,0);\
}
#endif//end of c__plusplus

#define __android_log_print(...) ""
#define printf(...)\
printf("[ BTFT LOG ] ");\
printf(__VA_ARGS__);
#else
#include <jni.h>
#include <android/log.h>
#define LOG_TAG "BTFT"
#define LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#define LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define LOGW(...)  __android_log_print(ANDROID_LOG_WARN,LOG_TAG,__VA_ARGS__)
#define LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#define LOGF(...)  __android_log_print(ANDROID_LOG_FATAL,LOG_TAG,__VA_ARGS__)

#ifdef DEBUG
char min_buffer[1000];
int buffer_index;
extern char min_buffer[1000];
extern int buffer_index;
#define printf(...) do{													\
						LOGD(__VA_ARGS__);				\
						if( buffer_index >= 1000){		\
							buffer_index = 0;}			\
						int len = sprintf(min_buffer + buffer_index,__VA_ARGS__);	\
						buffer_index += len;										\
						}while(0)
#else
#define printf(...) LOGD(__VA_ARGS__);
#endif//#end of DEBUG

#define BTFT(className, testCaseName)\
IN_BTFT(className, testCaseName,com_intel_btft_hello)

#define IN_BTFT(className, testCaseName, package)\
extern "C" int testCaseName();\
extern "C"{\
JNIEXPORT jboolean JNICALL \
Java##_##package##_##className##_##testCaseName(JNIEnv *env, jobject jobj)\
{\
	if(testCaseName()==0)\
	{return JNI_TRUE;}\
	else\
	{return JNI_FALSE;}\
}\
}
#endif//end of standalone

#endif//end of TEST_H_
