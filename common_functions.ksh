
#!/bin/ksh
##############################################################################
##                                                                          
##  Copyright (c) Mich Talebzadeh 1998                                    
##                                                                        
##  This work is unpublished and subject to copyright laws, all rights   
##  reserved.  This software has been distributed solely for the internal 
##  use of Peridale Ltd and its subsiduary companies. Use or         
##  disclosure by other parties without prior consent of the Bank is    
##  prohibited.                                                        
##                                                                    
#
#--------------------------------------------------------------------------------
#
# Procedure: 	common_functions.ksh
#
# Description:	Adapted for Spark programs
#
# Parameters:	see below
#
# Author:	Mich Talebzadeh
#--------------------------------------------------------------------------------
# Vers|  Date  | Who | DA | Description     
#-----+--------+-----+----+-----------------------------------------------------
# 1.0 |14/08/16|  MT |    | Initial Version
#-----+--------+-----+----+-----------------------------------------------------
#-----+--------+-----+----+-----------------------------------------------------
# 2.0 |06/10/02|  MT |    | Added minimal columns to replication defs
##############################################################################
#
function default_settings {
export PACKAGES="com.databricks:spark-csv_2.11:1.3.0"
export SCHEDULER="spark.scheduler.mode=FIFO"
export EXTRAJAVAOPTIONS="spark.executor.extraJavaOptions=-XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
export JARS="/home/hduser/jars/spark-streaming-kafka-assembly_2.11-1.6.1.jar"
export SPARKUI="spark.ui.port="
export SPARKDRIVERPORT="spark.driver.port=54631"
export SPARKFILESERVERPORT="spark.fileserver.port=54731"
export SPARKBLOCKMANAGERPORT="spark.blockManager.port=54832"
export SPARKKRYOSERIALIZERBUFFERMAX="spark.kryoserializer.buffer.max=512"
}
#
function run_local {
default_settings
if [[ -z ${SP} ]]
then
        SPARKUIPORT="${SPARKUI}55555"
else
        SPARKUIPORT="${SPARKUI}${SP}"
fi

${SPARK_HOME}/bin/spark-submit \
                --packages ${PACKAGES} \
                --driver-memory 5G \
                --num-executors 1 \
                --executor-memory 1G \
                --master local[2] \
                --conf "${SCHEDULER}" \
                --conf "${EXTRAJAVAOPTIONS}" \
                --jars ${JARS} \
                --class "${FILE_NAME}" \
                --conf "${SPARKUIPORT}" \
                --conf "${SPARKDRIVERPORT}" \
                --conf "${SPARKFILESERVERPORT}" \
                --conf "${SPARKBLOCKMANAGERPORT}" \
                --conf "${SPARKKRYOSERIALIZERBUFFERMAX}" \
                --conf spark.executor.memoryOverhead=3000 \
                --driver-class-path /tmp/${APPLICATION}.conf \
                --files /tmp/${APPLICATION}.conf \
                --conf "spark.executor.extraJavaOptions=-Dconfig.resource=application.conf" \
                --conf spark.driver.extraJavaOptions="-Dconfig.file=/tmp/${APPLICATION}.conf" \
                ${JAR_FILE}
}
#
function run_standalone {
default_settings:
if [[ -z ${SP} ]]
then
        SPARKUIPORT="${SPARKUI}55555"
else
        SPARKUIPORT="${SPARKUI}${SP}"
fi

${SPARK_HOME}/bin/spark-submit \
                --packages ${PACKAGES} \
                --driver-memory 4G \
                --executor-memory 2G \
                --num-executors 2 \
                --executor-cores 2 \
                --master spark://gcp-server:7077 \
                --conf "${SCHEDULER}" \
                --conf "${EXTRAJAVAOPTIONS}" \
                --jars ${JARS} \
                --class "${FILE_NAME}" \
                --conf "${SPARKUIPORT}" \
                --conf "${SPARKDRIVERPORT}" \
                --conf "${SPARKFILESERVERPORT}" \
                --conf "${SPARKBLOCKMANAGERPORT}" \
                --conf "${SPARKKRYOSERIALIZERBUFFERMAX}" \
                --conf spark.executor.memoryOverhead=1000 \
                --driver-class-path /home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf \
                --files /home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf \
                --conf "spark.executor.extraJavaOptions=-Dconfig.resource=application.conf" \
                --conf spark.driver.extraJavaOptions="-Dconfig.file=/home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf" \
                ${JAR_FILE}
}
#
function run_yarn {
default_settings
if [[ -z ${SP} ]]
then
        SPARKUIPORT="${SPARKU}55555"
else
        SPARKUIPORT="${SPARKUI}${SP}"
fi

${SPARK_HOME}/bin/spark-submit \
                --packages ${PACKAGES} \
                --executor-memory 2G \
                --num-executors 2 \
                --executor-cores 1 \
                --master yarn \
                --deploy-mode client \
                --conf "${SCHEDULER}" \
                --conf "${EXTRAJAVAOPTIONS}" \
                --jars ${JARS} \
                --class "${FILE_NAME}" \
                --conf "${SPARKUIPORT}" \
                --conf "${SPARKDRIVERPORT}" \
                --conf "${SPARKFILESERVERPORT}" \
                --conf "${SPARKBLOCKMANAGERPORT}" \
                --conf "${SPARKKRYOSERIALIZERBUFFERMAX}" \
                --conf spark.executor.memoryOverhead=3000 \
                --driver-class-path /home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf \
                --files /home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf \
                --conf "spark.executor.extraJavaOptions=-Dconfig.resource=application.conf" \
                --conf spark.driver.extraJavaOptions="-Dconfig.file=/home/hduser/dba/bin/scala/${APPLICATION}/src/main/scala/myPackage/${APPLICATION}.conf" \
                ${JAR_FILE}
}
#
function run_yarn_low {
default_settings
if [[ -z ${SP} ]]
then
        SPARKUIPORT="${SPARKU}55555"
else
        SPARKUIPORT="${SPARKUI}${SP}"
fi

${SPARK_HOME}/bin/spark-submit \
                --packages ${PACKAGES} \
                --executor-memory 8G \
                --num-executors 3 \
                --executor-cores 4 \
                --master yarn \
                --deploy-mode client \
                --conf "${SCHEDULER}" \
                --conf "${EXTRAJAVAOPTIONS}" \
                --jars ${JARS} \
                --class "${FILE_NAME}" \
                --conf "${SPARKUIPORT}" \
                --conf "${SPARKDRIVERPORT}" \
                --conf "${SPARKFILESERVERPORT}" \
                --conf "${SPARKBLOCKMANAGERPORT}" \
                --conf "${SPARKKRYOSERIALIZERBUFFERMAX}" \
                --conf spark.yarn.executor.memoryOverhead=3000 \
                ${JAR_FILE}
}
#
#libraryDependencies += "com.aerospike" %% "aerospike-spark" % "1.1.9"
#
function create_sbt_file {
        SBT_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/${FILE_NAME}.sbt
        [ -f ${SBT_FILE} ] && rm -f ${SBT_FILE}
        cat >> $SBT_FILE << !
    name := "${APPLICATION}"
    version := "1.0"
    scalaVersion := "2.11.8"

##libraryDependencies += "org.apache.spark" %% "spark-core" % "2.0.0" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-hive" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-streaming" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-streaming-kafka" % "1.6.1" % "provided"
libraryDependencies += "org.apache.phoenix" % "phoenix-spark" % "4.6.0-HBase-1.0"
libraryDependencies += "org.apache.hbase" % "hbase" % "1.2.6"
libraryDependencies += "org.apache.hbase" % "hbase-client" % "1.2.6"
libraryDependencies += "org.apache.hbase" % "hbase-common" % "1.2.6"
libraryDependencies += "org.apache.hbase" % "hbase-server" % "1.2.6"
libraryDependencies += "org.mongodb.spark" %% "mongo-spark-connector" % "2.2.0"
libraryDependencies += "org.mongodb" % "mongo-java-driver" % "3.8.1"
libraryDependencies += "org.apache.spark" %% "spark-streaming-twitter" % "1.6.3"
libraryDependencies += "com.google.cloud.bigdataoss" % "bigquery-connector" % "0.13.4-hadoop3"
libraryDependencies += "com.google.cloud.bigdataoss" % "gcs-connector" % "1.9.4-hadoop3"
libraryDependencies += "com.google.code.gson" % "gson" % "2.8.5"
libraryDependencies += "com.google.guava" % "guava" % "27.0.1-jre"
libraryDependencies += "org.apache.httpcomponents" % "httpcore" % "4.4.8"
libraryDependencies += "com.hortonworks" % "shc-core" % "1.1.1-2.1-s_2.11"
libraryDependencies += "io.delta" %% "delta-core" % "0.3.0"
!
}
#
function create_build_sbt_file {
        BUILD_SBT_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/build.sbt
        [ -f ${BUILD_SBT_FILE} ] && rm -f ${BUILD_SBT_FILE}
        cat >> $BUILD_SBT_FILE << !
lazy val root = (project in file(".")).
  settings(
    name := "${APPLICATION}",
    version := "1.0",
    scalaVersion := "2.11.8",
    mainClass in Compile := Some("myPackage.${APPLICATION}")
  )


libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "2.4.0"
libraryDependencies += "org.apache.spark" %% "spark-core" % "2.4.3"  % "provided" exclude("org.apache.hadoop", "hadoop-client")
resolvers += "Akka Repository" at "http://repo.akka.io/releases/"
resolvers += "Hortonworks Repository" at "http://repo.hortonworks.com/content/repositories/releases/"
resolvers += "Tabmo repository" at "https://dl.bintray.com/tabmo/maven/"
resolvers += "Typesafe Repo" at "http://repo.typesafe.com/typesafe/releases/"    
libraryDependencies += "com.amazonaws" % "aws-java-sdk" % "1.7.8"
libraryDependencies += "commons-io" % "commons-io" % "2.4"
libraryDependencies += "javax.servlet" % "javax.servlet-api" % "3.0.1" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-sql" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-hive" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-streaming" % "2.4.3" % "provided"
libraryDependencies += "org.apache.spark" %% "spark-streaming-kafka" % "1.6.1" % "provided"
libraryDependencies += "org.apache.phoenix" % "phoenix-spark" % "4.6.0-HBase-1.0"
libraryDependencies += "org.apache.hbase" % "hbase" % "1.2.3"
libraryDependencies += "org.apache.hbase" % "hbase-client" % "1.2.6"
libraryDependencies += "org.apache.hbase" % "hbase-common" % "1.2.6"
libraryDependencies += "org.apache.hbase" % "hbase-server" % "1.2.6"
libraryDependencies += "org.mongodb.spark" %% "mongo-spark-connector" % "2.2.0"
libraryDependencies += "org.mongodb" % "mongo-java-driver" % "3.8.1"
libraryDependencies += "org.apache.spark" %% "spark-streaming-twitter" % "1.6.3"
libraryDependencies += "com.google.cloud.bigdataoss" % "bigquery-connector" % "0.13.4-hadoop3"
libraryDependencies += "com.google.cloud.bigdataoss" % "gcs-connector" % "1.9.4-hadoop3"
libraryDependencies += "com.google.code.gson" % "gson" % "2.8.5"
libraryDependencies += "com.google.guava" % "guava" % "27.0.1-jre"
libraryDependencies += "org.apache.httpcomponents" % "httpcore" % "4.4.8"
libraryDependencies += "com.hortonworks" % "shc-core" % "1.1.1-2.1-s_2.11"
libraryDependencies += "com.typesafe.play" %% "play-json" % "2.7.3"
libraryDependencies += "com.typesafe" % "config" % "1.3.0"
libraryDependencies += "io.delta" %% "delta-core" % "0.3.0"

// META-INF discarding

assemblyMergeStrategy in assembly := {
 case PathList("META-INF", xs @ _*) => MergeStrategy.discard
 case x => MergeStrategy.first
}
!
}
#
function create_build_sbt_file_new {
        BUILD_SBT_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/build.sbt
        [ -f ${BUILD_SBT_FILE} ] && rm -f ${BUILD_SBT_FILE}
        cat >> $BUILD_SBT_FILE << !
  lazy val commonSettings = Seq(
  name := "${APPLICATION}",
  version := "1.0",
  scalaVersion := "2.11.8",
)

lazy val shaded = (project in file("."))
 .settings(commonSettings)

mainClass in Compile := Some("myPackage.${APPLICATION}")

libraryDependencies ++= Seq(
 "org.apache.spark" % "spark-sql_2.11" % "2.3.2" % "provided",
 "org.apache.spark" %% "spark-core" % "2.0.0" % "provided",
 "org.apache.spark" %% "spark-sql" % "2.0.0" % "provided",
 "org.apache.spark" %% "spark-hive" % "2.0.0" % "provided",
 "org.apache.spark" %% "spark-streaming" % "2.0.0" % "provided",
 "org.apache.spark" %% "spark-streaming-kafka" % "1.6.1" % "provided",
 "org.apache.phoenix" % "phoenix-spark" % "4.6.0-HBase-1.0",
 "org.apache.hbase" % "hbase" % "1.2.3",
 "org.apache.hbase" % "hbase-client" % "1.2.6",
 "org.apache.hbase" % "hbase-common" % "1.2.6",
 "org.apache.hbase" % "hbase-server" % "1.2.6",
 "org.mongodb.spark" %% "mongo-spark-connector" % "2.2.0",
 "org.mongodb" % "mongo-java-driver" % "3.8.1",
 "org.apache.spark" %% "spark-streaming-twitter" % "1.6.3",
 "com.google.cloud.bigdataoss" % "bigquery-connector" % "0.13.4-hadoop3",
 "com.google.cloud.bigdataoss" % "gcs-connector" % "1.9.4-hadoop3",
 "com.google.code.gson" % "gson" % "2.8.5",
 "com.google.guava" % "guava" % "27.0.1-jre",
 "org.apache.httpcomponents" % "httpcore" % "4.4.8",
  "com.aerospike" %% "aerospike-spark" % "1.1.9"
)
assemblyShadeRules in assembly := Seq(
  ShadeRule.rename("com.google.common.**" -> "repackaged.com.google.common.@1").inAll
)
!
}
#

function create_assembly_sbt_file {
        ASSEMBLY_SBT_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/project/assembly.sbt
        PLUGINS_SBT_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/project/plugins.sbt
        [ -f ${ASSEMBLY_SBT_FILE} ] && rm -f ${ASSEMBLY_SBT_FILE}
        [ -f ${PLUGINS_SBT_FILE} ] && rm -f ${PLUGINS_SBT_FILE}
        cat >> $ASSEMBLY_SBT_FILE << !
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.6")
////addSbtPlugin("com.typesafe.sbt" %% "sbt-native-packager" % "1.1.4")
//addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.12.0")
!
ln -fs $ASSEMBLY_SBT_FILE $PLUGINS_SBT_FILE
}
#
function create_mvn_file {
        MVN_FILE=${GEN_APPSDIR}/scala/${APPLICATION}/pom.xml
        [ -f ${MVN_FILE} ] && rm -f ${MVN_FILE}
        cat >> $MVN_FILE << !
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
<modelVersion>4.0.0</modelVersion>
<groupId>spark</groupId>
<version>1.0</version>
<name>\${project.artifactId}</name>

<properties>
<maven.compiler.source>1.7</maven.compiler.source>
<maven.compiler.target>1.7</maven.compiler.target>
<encoding>UTF-8</encoding>
<scala.version>2.10.4</scala.version>
<maven-scala-plugin.version>2.15.2</maven-scala-plugin.version>
</properties>

<dependencies>
  <dependency>
    <groupId>org.scala-lang</groupId>
    <artifactId>scala-library</artifactId>
    <version>2.11.7</version>
  </dependency>
<dependency>
<groupId>org.apache.spark</groupId>
<artifactId>spark-core_2.10</artifactId>
<version>2.0.0</version>
</dependency>
<dependency>
<groupId>org.apache.spark</groupId>
<artifactId>spark-sql_2.10</artifactId>
<version>2.0.0</version>
</dependency>
<dependency>
<groupId>org.apache.spark</groupId>
<artifactId>spark-hive_2.10</artifactId>
<version>2.0.0</version>
</dependency>
<dependency>
<groupId>com.databricks</groupId>
<artifactId>spark-csv_2.11</artifactId>
<version>1.3.0</version>
</dependency>
<dependency>
<groupId>org.apache.spark</groupId>
<artifactId>spark-streaming-kafka_2.10</artifactId>
<version>1.5.1</version>
</dependency>
<dependency>
<groupId>org.apache.spark</groupId>
<artifactId>spark-streaming-twitter_2.10</artifactId>
<version>1.6.1</version>
</dependency>
<dependency>
<groupId>org.twitter4j</groupId>
<artifactId>twitter4j-core</artifactId>
<version>2.1.4</version>
</dependency>
<dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
    <version>2.6.2</version>
</dependency>
<dependency>
    <groupId>org.apache.phoenix</groupId>
    <artifactId>phoenix-spark</artifactId>
    <version>4.6.0-HBase-1.0</version>
</dependency>
<dependency>
    <groupId>com.univocity</groupId>
    <artifactId>univocity-parsers</artifactId>
    <version>1.5.1</version>
</dependency>
</dependencies>

<build>
<sourceDirectory>src/main/scala</sourceDirectory>
<plugins>
<plugin>
<groupId>org.scala-tools</groupId>
<artifactId>maven-scala-plugin</artifactId>
<version>\${maven-scala-plugin.version}</version>
<executions>
<execution>
<goals>
<goal>compile</goal>
</goals>
</execution>
</executions>
<configuration>
<jvmArgs>
<jvmArg>-Xms64m</jvmArg>
<jvmArg>-Xmx1024m</jvmArg>
</jvmArgs>
</configuration>
</plugin>
<plugin>
<groupId>org.apache.maven.plugins</groupId>
<artifactId>maven-shade-plugin</artifactId>
<version>1.6</version>
<executions>
<execution>
<phase>package</phase>
<goals>
<goal>shade</goal>
</goals>
<configuration>
<filters>
<filter>
<artifact>*:*</artifact>
<excludes>
<exclude>META-INF/*.SF</exclude>
<exclude>META-INF/*.DSA</exclude>
<exclude>META-INF/*.RSA</exclude>
</excludes>
</filter>
</filters>
<transformers>
<transformer
implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
<mainClass>com.group.id.Launcher1</mainClass>
</transformer>
</transformers>
</configuration>
</execution>
</executions>
</plugin>
</plugins>
</build>

<artifactId>scala</artifactId>
</project>
!
}
#
function clean_up
{
if [[ "${TYPE}" = "sbt" ]]
then
        [ -f ${SBT_FILE} ] && rm -f ${SBT_FILE}
elif [[ "${TYPE}" = "assembly" ]]
then
        [ -f ${BUILD_SBT_FILE} ] && rm -f ${BUILD_SBT_FILE}
        [ -f ${ASSEMBLY_SBT_FILE} ] && rm -f ${ASSEMBLY_SBT_FILE}
else
        [ -f ${MVN_FILE} ] && rm -f ${MVN_FILE}
fi
}
