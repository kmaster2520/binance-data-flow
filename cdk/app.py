import aws_cdk as cdk
from stack import FirehoseTransformStack

app = cdk.App()

FirehoseTransformStack(
    app,
    "FirehoseTransformStack",
    env=cdk.Environment(account="391262527903", region="us-east-1"),
)

app.synth()
