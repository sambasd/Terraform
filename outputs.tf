output "server_details" {
  description = "Details of all provisioned RHEL servers"

  value = {
    for instance in aws_instance.rhel_servers :
    instance.tags["Name"] => {
      instance_id       = instance.id
      public_ip         = instance.public_ip
      private_ip        = instance.private_ip
      instance_type     = instance.instance_type
      availability_zone = instance.availability_zone
      subnet_id         = instance.subnet_id
      security_groups   = instance.vpc_security_group_ids
      ami_id            = instance.ami
      instance_state    = instance.instance_state
    }
  }
}

output "ssh_commands" {
  description = "SSH commands for connecting to the servers"

  value = {
    for instance in aws_instance.rhel_servers :
    instance.tags["Name"] =>
    "ssh -i rhel-terraform-key.pem ec2-user@${instance.public_ip}"
  }
}