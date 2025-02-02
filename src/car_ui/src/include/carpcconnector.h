

#ifndef libCarPcConnector__h
#define libCarPcConnector__h

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#ifdef __cplusplus
extern "C"
{
#endif

EXPORT const char* SendMessage(const char* message);

/** Version of the native C library */
EXPORT const char* const library_version = "0.0.1-native";

#ifdef __cplusplus
}
#endif

#endif