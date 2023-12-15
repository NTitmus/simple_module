
resource "aws_instance" "example" {
    instance_type = "t2.microzzz"
    ami = var.instance_ami
}