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
    project.evaluationDependsOn(":app")
}

// Workaround: ensure typedefs.txt exists for sqflite_android (AGP 8.x)
subprojects {
    val p = project
    fun setupSqfliteTypedefs() {
        if (p.name != "sqflite_android") return
        val createTypedefs = p.tasks.register("createSqfliteTypedefs") {
            doLast {
                val dir = p.layout.buildDirectory.get()
                    .dir("intermediates/annotations_typedef_file/debug/extractDebugAnnotations")
                    .asFile
                dir.mkdirs()
                java.io.File(dir, "typedefs.txt").writeText("")
            }
        }
        p.tasks.findByName("extractDebugAnnotations")?.dependsOn(createTypedefs)
    }
    if (p.state.executed) {
        setupSqfliteTypedefs()
    } else {
        p.afterEvaluate { setupSqfliteTypedefs() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
