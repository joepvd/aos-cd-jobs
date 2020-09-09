#!/usr/bin/env groovy

node {
    checkout scm
    def buildlib = load("pipeline-scripts/buildlib.groovy")
    def commonlib = buildlib.commonlib
    commonlib.describeJob("sweep", """
        <h2>Sweep bugs</h2>
        <b>Timing</b>: This runs after component builds (ocp3/ocp4/custom jobs),
        or when preparing a nightly for examination by QE.

        After component builds, bugs are queried that are in MODIFIED state,
        and are set to ON_QA. This is the signal to QE that they can test the bug.
        In this mode of operation, ATTACH_BUGS is false.

        When preparing a set of nightlies and advisories for QE, the sweep job will
        look for all bugs that are in ON_QA or VERIFIED state, and attach them
        to the default advisories, according to those recorded in ocp-build-data
        group.yml.
        For 3.11, all bugs are swept into the rpm advisory.
        For 4.y, bugs are swept into the image or extras advisory.
        CVEs are not currently swept by this job at all.

        Optionally, builds from our brew candidate tags may also be swept. If necessary,
        the advisory will be first set to NEW_FILES.
    """)


    properties(
        [
            disableResume(),
            buildDiscarder(
                logRotator(
                    artifactDaysToKeepStr: '',
                    artifactNumToKeepStr: '',
                    daysToKeepStr: '',
                    numToKeepStr: '90'
                )
            ),
            [
                $class : 'ParametersDefinitionProperty',
                parameterDefinitions: [
                    commonlib.ocpVersionParam('BUILD_VERSION'),
                    booleanParam(
                        name: 'SWEEP_BUILDS',
                        defaultValue: true,
                        description: 'Sweep and attach builds to advisories',
                    ),
                    booleanParam(
                        name: 'ATTACH_BUGS',
                        defaultValue: false,
                        description: 'Attach bugs to their advisories',
                    ),
                    commonlib.dryrunParam(),
                    commonlib.mockParam(),
                ],
            ],
        ]
    )

    commonlib.checkMock()

    def version = params.BUILD_VERSION
    doozerOpts = "--group openshift-${version}"
    stage("Init") {
        echo "Initializing bug sweep for ${version}. Sync: #${currentBuild.number}"
        currentBuild.displayName = "${version} bug sweep"

        buildlib.elliott "--version"
        sh "which elliott"

        buildlib.kinit()
    }

    // short circuit to UNSTABLE (not FAILURE) when automation is frozen
    if (!buildlib.isBuildPermitted(doozerOpts)) {
        currentBuild.result = 'UNSTABLE'
        currentBuild.description = 'Builds not permitted'
        echo('This build is being terminated because it is not permitted according to current group.yml')
        return
    }

    def (major, minor) = commonlib.extractMajorMinorVersionNumbers(version)

    currentBuild.description = "Repairing state and sweeping new bugs.\n"

    if (params.ATTACH_BUGS) {
        stage("Attach bugs to advisories") {
            currentBuild.description += "* Attaching ON_QA and VERIFIED bugs to default advisories\n"
            cmd = [
                "--group=openshift-${version}",
                "find-bugs",
                "--mode sweep",
                "--status ON_QA",
                "--status VERIFIED",
                "--into-default-advisories",
            ]
            if (params.DRY_RUN) {
                cmd << "--dry-run"
            }
            retry (3) {
                try {
                    buildlib.elliott(cmd.join(' '))
                } catch (Exception elliottErr) {
                    echo("Error attaching bugs to advisories (will retry a few times):\n${elliottErr}")
                    sleep(time: 1, unit: 'MINUTES')
                    throw elliottErr
                }
            }
        }
    } else {
        stage("Set MODIFIED bugs to ON_QA") {
            currentBuild.description += "* Changing MODIFIED bugs to ON_QA\n"
            cmd = [
                "--group=openshift-${version}",
                "find-bugs",
                "--mode qe",
            ]
            if (params.DRY_RUN) {
                cmd << "--dry-run"
            }
            retry(3) {
                try {
                    buildlib.elliott(cmd.join(" "))
                } catch (Exception elliottErr) {
                    echo("Error moving bugs to ON_QA (will retry):\n${elliottErr}")
                    sleep(time: 1, unit: 'MINUTES')
                    throw elliottErr
                }
            }
        }
    }

    stage("Sweep builds") {
        if (!params.SWEEP_BUILDS) {
            currentBuild.description += "* Not sweeping builds\n"
            return
        }
        if (params.DRY_RUN) {
            echo("Skipping attach builds to advisory for dry run")
            return
        }
        buildlib.attachBuildsToAdvisory(["rpm", "image"], params.BUILD_VERSION)
    }
    currentBuild.description = "Ran without errors\n---------------\n" + currentBuild.description
}
