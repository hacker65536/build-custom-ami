# vim:set foldmethod=marker:

resource "aws_codepipeline" "cpl" {
  name     = "${terraform.env}-cpl"
  role_arn = "${aws_iam_role.cpl.arn}"

  artifact_store {
    location = "${aws_s3_bucket.s3.bucket}"
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
        owner      = "techadmin"
        Repo       = "${var.github_repo}"
        Branch     = "${var.github_branch}"
        OAuthToken = "${var.github_token}"
      }
    }
  }
}
