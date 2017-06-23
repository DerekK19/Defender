node('Xcode8.3.3') {
  try {

    stage ('Build') {
      env.JENKINS_CFBundleVersion = VersionNumber(versionNumberString: '${BUILD_DATE_FORMATTED, "yyMMddHHmm"}')
      env.FASTLANE_DISABLE_COLORS = "1"
      env.LC_CTYPE = "en_US.UTF-8"
      checkout scm
      sh 'fastlane ios beta'
      sh 'fastlane mac home'
    }

    stage ('Deploy') {
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
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
  try {
    sh "jenkins-growl $buildStatus"
  } catch (e) {
    // Fail silently
  }
}
