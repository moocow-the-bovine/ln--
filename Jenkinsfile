/*-*- Mode: Groovy; coding: utf-8; -*-*/
pipeline {
    agent any
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
		docker { image 'buildpack-deps-moo:latest' }
		//label 'kira'
	    }
	    steps {
		sh 'make'
		//sh 'echo foo; echo bar; sleep 30' //-- works
	    }
	}

	//-- "test": test (dummy)
	stage('test') {
	    agent {
		docker { image 'buildpack-deps-moo:latest' }
		//label 'kira'
	    }
	    steps {
		//-- TAP formatting + jenkins TAP plugin
		///sh 'apt-get update && apt-get -y install libtap-harness-archive-perl' //-- permission denied
		//sh 'make PROVE_OPTS="--archive tap_output" test'
		//step([$class: "TapPublisher", testResults: "tap_output/**/*.t"]) //-- "publish" tap results for buntiklicki jenkins "TAP" plugin

		//-- JUnit formatting + jenkins JUnit plugin
		sh 'make PROVE_OPTS="--archive tap_output --formatter TAP::Formatter::JUnit" test'
		junit 'tap_output/**/*.junit.xml'
	    }
	}

	//-- "archive": archive built artifacts (--> "artifact introduced outside jenkins" is irritating)
	stage('archive') {
	    agent {
		docker { image 'buildpack-deps-moo:latest' }
		//label 'kira'
	    }
	    steps {
		archiveArtifacts artifacts: 'ln--', onlyIfSuccessful:true, fingerprint:true
		//sh 'make clean'
	    }
	}
    }

    post {
	//-- see https://jenkins.io/doc/pipeline/tour/post/
	/*
	always {
	    echo "Archiving artifacts for build ${env.BUILD_NUMBER}"
	    archiveArtifacts artifacts: 'ln--', onlyIfSuccessful:true, fingerprint:true
            //echo 'One way or another, I have finished'
            deleteDir() //-- clean up our workspace
	}
	*/
        success {
            echo 'Pipeline completed successfully :)'
	    //deleteDir()
        }
        unstable {
            echo 'Pipeline unstable :/'
        }
        failure {
            echo 'Pipeline FAILED :('
        }
        changed {
            echo 'Pipeline status CHANGED :P'
        }
    }
}
