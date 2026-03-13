allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (hasProperty("android")) {
            val androidExt = extensions.getByName("android") as? com.android.build.gradle.BaseExtension
            if (androidExt?.namespace == null) {
                androidExt?.namespace = "com.example." + project.name.replace("-", "_")
            }
            androidExt?.compileSdkVersion(36)
        }
    }
    
    // Fix for older plugins (like isar_flutter_libs) that have the package attribute in AndroidManifest.xml under AGP 8.0+
    val manifestFile = file("src/main/AndroidManifest.xml")
    if (manifestFile.exists()) {
        val content = manifestFile.readText()
        if (content.contains("package=\"")) {
            manifestFile.writeText(content.replace(Regex("package=\"[^\"]*\""), ""))
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
