node{
	echo "${workspace}"
	echo "${env.BRANCH_NAME}"
	echo "${env.TAG_NAME}"
	echo "${env.JOB_NAME}"

	environment {
		registry = "$registry/crudapp"
		registryCredential = 'docker'
		dockerImage = ''
	}


	stage("clone"){
		tag = env.TAG_NAME
		echo "${tag}"
		if (tag == null){
			git branch: env.BRANCH_NAME, credentialsId: 'bitbucket', url: '$github_url'
		}
		else{
			//git branch: env.TAG_NAME, url: '$github_url'
			git credentialsId: 'bitbucket', url: '$github_url'
			sh "git checkout tags/${tag}"
		}
	}
	stage("build"){
		def mavenHome = tool name: "Maven363", type: "maven"
		def mavenCMD = "${mavenHome}/bin/mvn "
		sh "${mavenCMD} clean package"
	}

	stage("Nexus artifact upload"){
		def pom = readMavenPom file: 'pom.xml'
		filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
		artifactPath = filesByGlob[0].path;
		echo "Path: ${artifactPath}"
		switch(env.BRANCH_NAME){
			case "develop":
				nexusArtifactUploader artifacts: [[artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus', groupId: pom.groupId, nexusUrl: '$nexus_url', nexusVersion: 'nexus3', protocol: 'http', repository: 'dev', version: pom.version
				break
			case "release":
				nexusArtifactUploader artifacts: [[artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus', groupId: pom.groupId, nexusUrl: '$nexus_url', nexusVersion: 'nexus3', protocol: 'http', repository: 'qa', version: pom.version
				break
			case "master":
				nexusArtifactUploader artifacts: [[artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus', groupId: pom.groupId, nexusUrl: '$nexus_url', nexusVersion: 'nexus3', protocol: 'http', repository: 'stage', version: pom.version
				break
			default:
				nexusArtifactUploader artifacts: [[artifactId: pom.artifactId, classifier: '', file: artifactPath, type: pom.packaging]], credentialsId: 'nexus', groupId: pom.groupId, nexusUrl: '$nexus_url', nexusVersion: 'nexus3', protocol: 'http', repository: 'prod', version: pom.version
				break
		}
	}
	stage('Build and Push Docker Image') {
		switch(env.BRANCH_NAME){
			case "develop":
				sh label: '', script: '''docker build -t crudapp:$BUILD_NUMBER .
                             docker login -u $dockerUsername -p $dockerPassword
							 docker tag crudapp:$BUILD_NUMBER $registry/crudapp:$BUILD_NUMBER
                             docker push $registry/crudapp:$BUILD_NUMBER'''
				break
			case "release":
				sh label: '', script: '''docker build -t crudapp:$BUILD_NUMBER .
                             docker login -u $dockerUsername -p $dockerPassword
							 docker tag crudapp:$BUILD_NUMBER$registry/crudapp:$BUILD_NUMBER
                             docker push $registry/crudapp:$BUILD_NUMBER'''
				break
			case "master":
               sh label: '', script: '''docker build -t crudapp:$BUILD_NUMBER .
               aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 872154951115.dkr.ecr.us-east-1.amazonaws.com
               docker tag crudapp:$BUILD_NUMBER 872154951115.dkr.ecr.us-east-1.amazonaws.com/crudapp:$BUILD_NUMBER
               docker push 872154951115.dkr.ecr.us-east-1.amazonaws.com/crudapp:$BUILD_NUMBER'''
				break
                  
      }
   }
}