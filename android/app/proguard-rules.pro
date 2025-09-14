# ==== Firebase / Google Sign-In ====
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin metadata
-keep class kotlin.Metadata { *; }

# (opsional) Gson / OkHttp
# -keep class com.google.gson.** { *; }
# -dontwarn com.google.gson.**
# -dontwarn okhttp3.**
# -dontwarn okio.**
