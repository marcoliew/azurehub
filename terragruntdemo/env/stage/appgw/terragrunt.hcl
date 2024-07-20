# Find the root terragrunt.hcl and inherit its 
# configuration automatically.
include {
  path = find_in_parent_folders()
}

terraform {
  #source = "../../../modules/appgw"
  source = "https://github.com/marcoliew/terragruntsplitmodule.git//appgw?ref=v1.0.0"
}

inputs = {
  instance_type = "t2.micro"
  instance_name = "example-server-dev"
}