# Gson uses generic signatures and annotations when flutter_local_notifications
# reads its cached scheduled-notification payloads.
-keepattributes Signature
-keepattributes *Annotation*

-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Firebase Auth / Google Sign-In -- most Firebase SDKs bundle their own
# consumer ProGuard rules, but the auth flow specifically touches reflection
# for credential/token models, so keep it explicit rather than relying on
# an untested release build to surface a "works in debug, breaks in
# release" auth failure.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.firebase.**

# LiveKit / WebRTC -- native JNI bindings are easy for R8 to strip or
# rename incorrectly since the native side references classes by name.
-keep class org.webrtc.** { *; }
-keep class io.livekit.** { *; }
-dontwarn org.webrtc.**

# Any class with a native method: R8 can rename/strip these under
# aggressive obfuscation, breaking the JNI binding even though nothing
# looks wrong at the Kotlin/Java call site.
-keepclasseswithmembernames class * {
    native <methods>;
}
