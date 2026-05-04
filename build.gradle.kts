plugins {
    kotlin("jvm") version "1.9.22"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.apache.poi:poi:5.2.3")
    implementation("org.apache.poi:poi-ooxml:5.2.3")
}

kotlin {
    jvmToolchain(11)
}

application {
    mainClass.set("GradeCalculatorKt")
}
