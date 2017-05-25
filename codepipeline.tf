# vim:set foldmethod=marker:

resource "aws_iam_role" "cpl" {
  name               = "${terraform.env}-cpl-role"
  assume_role_policy = "${data.aws_iam_policy_document.clp_srv_role_assume.json}"
}

resource "aws_iam_role_policy" "cpl_policy" {
  role   = "${aws_iam_role.cpl.id}"
  policy = "${data.aws_iam_policy_document.clp_srv_role_policy.json}"
}

resource "aws_codepipeline" "cpl" {
  name     = "${terraform.env}-cpl"
  role_arn = "${aws_iam_role.cpl.arn}"

  artifact_store {
    location = "${aws_s3_bucket.s3.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["myapp"]

      configuration {
        Owner      = "${lookup(var.github,"owner")}"
        Repo       = "${lookup(var.github,"repo")}"
        Branch     = "${lookup(var.github,"branch")}"
        OAuthToken = "${lookup(var.github,"token")}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["myapp"]
      output_artifacts = ["myappbuild"]

      configuration {
        ProjectName = "${aws_codebuild_project.cb.name}"
      }
    }
  }
}
