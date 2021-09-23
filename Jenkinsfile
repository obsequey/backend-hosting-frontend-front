pipeline {
	agent any

	environment {
		GIT_REPO_NAME = env.GIT_URL.replaceFirst(/^.*\/([^\/]+?).git$/, '$1')
		SOME_SECRET_KEY = credentials('some-secret-key')
		REGISTRY_HOST = credentials('docker-registry-host')
		BACK_REPO_URL = 'https://github.com/obsequey/backend-hosting-frontend-back.git'
	}

	stages {
		stage('Build frontend') {
			steps {
				sh 'mkdir -p backend'
				sh 'mkdir -p backend/front'
				sh 'npm i'
				sh 'npm run build:prod'
				sh 'mv dist/user-list-front/* backend/front'
			}
		}

		stage('Build backend') {
			steps {
				dir('backend') {
					git(url: env.BACK_REPO_URL, branch: env.GIT_BRANCH, credentialsId: 'github')
					sh 'echo ${SOME_SECRET_KEY}'
					sh 'ls'
					sh 'docker build . -t "${REGISTRY_HOST}/${GIT_REPO_NAME}-${BRANCH_NAME}"'
					sh 'docker push ${REGISTRY_HOST}/${GIT_REPO_NAME}-${BRANCH_NAME}'
					sh 'docker stop ${GIT_REPO_NAME}-${BRANCH_NAME} || true'
					sh '''
						IMAGE_EXPOSED_PORT=`docker inspect ${REGISTRY_HOST}/${GIT_REPO_NAME}-${BRANCH_NAME} --format="{{json .Config.ExposedPorts}}" | egrep [0-9]+ -o | head -1`
						docker run -d --rm --name ${GIT_REPO_NAME}-${BRANCH_NAME} -p ${IMAGE_EXPOSED_PORT} ${REGISTRY_HOST}/${GIT_REPO_NAME}-${BRANCH_NAME}
					'''
					sh '''
						JENKINS_IMAGE_PORT=`docker port ${GIT_REPO_NAME}-${BRANCH_NAME} | egrep [0-9]+$ -o | head -1`
						echo "localhost:$JENKINS_IMAGE_PORT"
					'''

				}
			}
		}

	}

	post {
		always {
			node('master') {
				sh '''
					JENKINS_IMAGE_PORT=`docker port ${GIT_REPO_NAME}-${BRANCH_NAME} | egrep [0-9]+$ -o | head -1`
					echo "localhost:$JENKINS_IMAGE_PORT"
				'''
	      slackSend color: "good", message: "Build for ${env.GIT_REPO_NAME} (${env.BRANCH_NAME}) is successfull: http://${env.JENKINS_SERVER}:${env.JENKINS_IMAGE_PORT}"
			}
		}
	}
}
