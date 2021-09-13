node() {
    checkout scm
    def buildlib = load("pipeline-scripts/buildlib.groovy")
    def commonlib = buildlib.commonlib
    def slacklib = commonlib.slacklib
    buildlib.kinit()

    properties(
        [
            disableConcurrentBuilds(),
            [
                $class : 'ParametersDefinitionProperty',
                parameterDefinitions: [
                    commonlib.ocpVersionParam('BUILD_VERSION'),
                    booleanParam(
                        name: 'SEND_TO_SLACK',
                        defaultValue: true,
                        description: "If false, output will only be sent to console"
                    ),
                    commonlib.mockParam(),
                ]
            ],
        ]
    )

    commonlib.checkMock()

    timestamps {

        slackChannel = slacklib.to(BUILD_VERSION)

        report = """
            multi line

            slack
            message to be trimmed
            """
        if (report) {
            echo "The report:\n${report}"
            if (params.SEND_TO_SLACK) {
                slackChannel.say(":alert: Howdy! This is joep testing stuff \n${report}")
            }
        }
    }
}
