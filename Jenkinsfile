/*-*- Mode: Groovy; coding: utf-8; -*-*/
pipeline {
    agent none
    options {
	//-- abort if any stage fails
        skipStagesAfterUnstable()
    }    

    stages {
	//-- "hello": test 123
	stage('hello') {
	    agent {
		docker { image 'debian:stretch' }
	    }
	    steps {
                sh 'echo "Hello, jenkins"'
            }
	}

	//-- "build": build the project
	stage('build') {
	    agent {
		docker { image 'buildpack-deps:stretch' }
	    }
	    steps {
		sh 'pwd'
		sh 'ls -aF'
		sh 'make'
	    }
	}
    }
}
