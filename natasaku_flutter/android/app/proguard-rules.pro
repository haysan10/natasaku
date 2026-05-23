## Gson rules required by flutter_local_notifications scheduled notifications.
## Gson reads generic type information from class-file signatures.
-keepattributes Signature

## Keep annotations used by Gson adapters.
-keepattributes *Annotation*

## Gson specific classes.
-dontwarn sun.misc.**

## Prevent R8 from stripping adapter interface information.
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Prevent R8 from leaving serialized data object fields null.
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

## Retain generic signatures of TypeToken and its subclasses.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
