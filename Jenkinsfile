properties([buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))])

node('Xcode') {
  try {

    stage ('Build') {
      env.App_Name = "Defender"
      env.JENKINS_CFBundleVersion = VersionNumber(versionNumberString: '${BUILD_DATE_FORMATTED, "yyMMddHHmm"}')
      env.FASTLANE_DISABLE_COLORS = "1"
      env.LC_CTYPE = "en_US.UTF-8"
      checkout scm
      sh '''#!/bin/sh -l
      
       fastlane mac home
       fastlane ios beta
       
      '''
    }

    stage ('Package') {
      sh """#!/bin/sh -l
        cp "Deployment/Defender-512.png" "../FastlaneArtifacts/${App_Name}@512.png"
        cp "Deployment/InstallerBackground.png" "../FastlaneArtifacts/InstallerBackground.png"
        cp "Deployment/DefenderMac.json" "../FastlaneArtifacts/${App_Name}.json"

        cd ../FastlaneArtifacts
        rm -rf "${App_Name}.dmg"
        /usr/local/bin/appdmg "${App_Name}.json" "${App_Name}.dmg"

        cp "../FastlaneArtifacts/${App_Name}.dmg" "../FastlaneArtifacts/archives/${App_Name}-${JENKINS_CFBundleVersion}.dmg"
        cp "../FastlaneArtifacts/${App_Name}.app.dSYM.zip" "../FastlaneArtifacts/archives/${App_Name}-${JENKINS_CFBundleVersion}.app.dSYM.zip"
      """
    }

    stage ('Archive') {
        dir("../FastlaneArtifacts")
        {
            println(pwd())
            archiveArtifacts artifacts: "${env.App_Name}*.*", fingerprint: true, allowEmptyArchive: false, onlyIfSuccessful: true
        }
    }

  } catch (e) {
    // If there was an exception thrown, the build failed
    currentBuild.result = "FAILED"
    throw e
  } finally {
    // Success or failure, always send notifications
    notifyBuild(currentBuild.result)
  }

}

def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus =  buildStatus ?: 'SUCCESSFUL'

    // Default values
    def colorName = 'RED'
    def colorCode = '#FF0000'
    def colorBlink = 'FF0000'
    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL})"

    // Override default values based on build status
    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
        colorCode = 'FFFF00'
    } else if (buildStatus == 'SUCCESSFUL') {
        color = 'GREEN'
        colorCode = '#00FF00'
        colorBlink = '00FF00'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
        colorBlink = 'FF0000'
    }

    // Send notifications
    slackSend (color: colorCode, message: summary)
    try {
        sh "blink-cr flash $colorBlink"
        sh "jenkins-growl $buildStatus"
    } catch (e) {
        // Fail silently
    }
}
