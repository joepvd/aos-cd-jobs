#!/usr/bin/env groovy

import java.text.SimpleDateFormat

node {
    wrap([$class: "BuildUser"]) {
        checkout scm
        def lib = load("advisories.groovy")
        def buildlib = lib.buildlib
        def commonlib = lib.commonlib

        def dateFormat = new SimpleDateFormat("yyyy-MMM-dd")
        def date = new Date()

        commonlib.describeJob("advisories", """
            <h2>Create the standard advisories for a new release</h2>
            <b>Timing</b>: The "release" job runs this as soon as the previous release
            for this version is defined in the release-controller.

            For more details see the <a href="https://github.com/openshift/aos-cd-jobs/blob/master/jobs/build/advisories/README.md" target="_blank">README</a>
        """)

        // Please update README.md if modifying parameter names or semantics
        properties(
            [
                disableResume(),
                buildDiscarder(
                    logRotator(
                        artifactDaysToKeepStr: "",
                        artifactNumToKeepStr: "",
                        daysToKeepStr: "",
                        numToKeepStr: "")),
                [
                    $class: "ParametersDefinitionProperty",
                    parameterDefinitions: [
                        commonlib.ocpVersionParam("VERSION"),
                        booleanParam(
                            name: "REQUEST_LIVE_IDs",
                            description: "(No effect once SUPPRESS_EMAIL is checked) Sending emails request live ids to docs team once advisories are created",
                            defaultValue: true
                        ),
                        string(
                            name: "ASSIGNED_TO",
                            description: "Advisories are assigned to QE",
                            defaultValue: "openshift-qe-errata@redhat.com",
                            trim: true
                        ),
                        string(
                            name: "MANAGER",
                            description: "ART team manager (not release manager)",
                            defaultValue: "vlaad@redhat.com",
                            trim: true
                        ),
                        string(
                            name: "PACKAGE_OWNER",
                            description: "Must be an individual email address; may be anyone who wants random advisory spam",
                            defaultValue: "lmeyer@redhat.com",
                            trim: true
                        ),
                        choice(
                            name: "IMPETUS",
                            description: "For which reason are the advisories being created",
                            choices: [
                                "standard",
                                "cve",
                                "ga",
                                "test",
                            ].join("\n"),
                        ),
                        string(
                            name: "DATE",
                            description: "Intended release date. Format: YYYY-Mon-dd (example: 2050-Jan-01)",
                            defaultValue: "${dateFormat.format(date)}",
                            trim: true
                        ),
                        booleanParam(
                            name: "DRY_RUN",
                            description: "Take no action, just echo what the job would have done.",
                            defaultValue: false
                        ),
                        commonlib.suppressEmailParam(),
                        string(
                            name: "MAIL_LIST_FAILURE",
                            description: "Failure Mailing List",
                            defaultValue: [
                                "aos-art-automation+failed-ocp4-build@redhat.com"
                            ].join(","),
                            trim: true
                        ),
                        string(
                            name: 'LIVE_ID_MAIL_LIST',
                            description: 'Current default is OpenShift CCS Mailing List and OpenShift ART',
                            defaultValue: [
                                "openshift-ccs@redhat.com",
                                "aos-team-art@redhat.com"
                            ].join(","),
                            trim: true
                        ),
                        commonlib.mockParam(),
                    ]
                ],
            ]
        )   // Please update README.md if modifying parameter names or semantics

        commonlib.checkMock()

        currentBuild.displayName = "${params.VERSION}.z advisories${params.DRY_RUN ? " [DRY_RUN]" : ""}"
        currentBuild.description = ""
        def (major, minor) = commonlib.extractMajorMinorVersionNumbers(params.VERSION)

        stage("test venv") {
            buildlib.doozer("--version")
            buildlib.elliott("--version")
            sh "which elliott"
            sh "which doozer"
            sh "which pip"
            sh "which python"
        }
    }
}
