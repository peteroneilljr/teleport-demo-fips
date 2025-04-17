# ---------------------------------------------------------------------------- #
# EC2 agent_nodename Instance Profile - Console Access
# ---------------------------------------------------------------------------- #
resource "aws_iam_role" "console_access" {
  name_prefix = "TeleportConsole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_console_assume_ro" {
  role       = aws_iam_role.console_access.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/ReadOnlyAccess"
}
resource "aws_iam_instance_profile" "console_access" {
  name_prefix = "TeleportProfile"

  role = aws_iam_role.console_access.name
}

# ---------------------------------------------------------------------------- #
# Teleport IAM Assume RO Role
# ---------------------------------------------------------------------------- # 
resource "aws_iam_role" "teleport_assume_ro" {
  name_prefix = "TeleportReadOnly"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.console_access.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "teleport_assume_ro" {
  role       = aws_iam_role.teleport_assume_ro.name
  policy_arn = "arn:aws-us-gov:iam::aws:policy/ReadOnlyAccess"
}
