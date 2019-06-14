/*-*- Mode: Groovy; coding: utf-8; -*-*/
pipeline {
    agent none
    options {
	//-- abort if any stage fails
        skipStagesAfterUnstable()
    }    

    stages {
	//-- "hello": test 123
	/*
	stage('hello') {
	    agent {
		docker { image 'debian:stretch' }
	    }
	    steps {
                sh 'echo "Hello, jenkins"'
            }
	}
	 */

	//-- "build": build the project
	stage('build') {
	    agent {
		docker { image 'buildpack-deps:stretch' }
	    }
	    steps {
		sh 'make'
		//sh 'echo foo; echo bar; sleep 30' //-- works
	    }
	}

	//-- "test": test (dummy)
	stage('test') {
	    agent {
		docker { image 'buildpack-deps:stretch-moo' }
	    }
	    steps {
		//sh 'apt-get update && apt-get -y install libtap-harness-archive-perl' //-- permission denied
		sh 'mkdir tap_output'
		sh 'make PROVE_OPTS="--archive tap_output" test'
	    }
	}

    }
}
