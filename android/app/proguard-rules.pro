# Release builds are shrunk by R8. Classes below are created by reflection, which R8 cannot see.

# Room creates generated databases (e.g. WorkManager's WorkDatabase_Impl, pulled in by
# Google Mobile Ads) through their no-arg constructor. Without this rule R8 strips the
# constructor and the app crashes at launch in androidx.startup.InitializationProvider.
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
