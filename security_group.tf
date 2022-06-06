resource "aws_security_group" "egress-all-all" {
  name = "egress-all-all"

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ingress-all-all" {
  name = "ingress-all-all"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# TODO: replace ingress-all-all with specific rules needed
# Open protocols and ports between the hosts

# The following ports must be available. On some systems, these ports are open by default.

#     TCP port 2377 for cluster management communications
#     TCP and UDP port 7946 for communication among nodes
#     UDP port 4789 for overlay network traffic

# If you plan on creating an overlay network with encryption (--opt encrypted), you also need to ensure ip protocol 50 (ESP) traffic is allowed.
