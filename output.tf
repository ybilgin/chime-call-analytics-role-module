##################################################################################
# OUTPUTS
##################################################################################

output "chime_call_analytics_role_name" {
  value = aws_iam_role.chime_call_analytics_role.name
}

output "chime_call_analytics_role_arn" {
  value = aws_iam_role.chime_call_analytics_role.arn
}