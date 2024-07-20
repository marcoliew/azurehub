# Find the root terragrunt.hcl and inherit its 
# configuration automatically.
include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/backend"
}

inputs = {
  instance_type = "t2.micro"
  instance_name = "example-server-dev"
}