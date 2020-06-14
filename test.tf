provider "aws" {
  region = "ap-south-1"
  profile = "user1"
}
resource "aws_security_group" "securitytask" {
  name        = "securitytask"
  description = "Security Group"
  vpc_id      = "vpc-29e4f841"
  ingress {
    description = "SSH Rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "osinstance24" {
  ami  = "ami-0447a12f28fddb066"
  instance_type = "t2.micro"
  key_name ="mytest24" 
  security_groups =  ["securitytask"]

   connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Shruti/Downloads/mytest24.pem")
    host     = aws_instance.osinstance24.public_ip
  }
  
provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd  php git -y",
      "sudo systemctl restart httpd",
       "sudo systemctl enable httpd",
    
    ]
  }

tags = {
    Name = "osinstance2"
  
  }
}
resource "aws_ebs_volume" "ebs24" {
  availability_zone = aws_instance.osinstance24.availability_zone
  size              = 1
  tags = {
    Name = "lwebs"
  }
}

resource "aws_volume_attachment" "ebsatt24" {
  device_name = "/dev/sdf"
  volume_id   = "${aws_ebs_volume.ebs24.id}"
  instance_id = "${aws_instance.osinstance24.id}"
}

output "myos_ip" {
  value = aws_instance.osinstance24.public_ip
}

resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.osinstance24.public_ip} > publicip.txt"
  	}
}
resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebsatt24,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Shruti/Downloads/mytest24.pem")
    host     = aws_instance.osinstance24.public_ip
  }
provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo git clone https://github.com/shruti004/task-1.git  /var/www/html"
    ]
  }
}
resource "null_resource" "nulllocal1"  {


depends_on = [
    null_resource.nullremote3,
  ]

	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.osinstance24.public_ip}"
  	}
}
resource "aws_s3_bucket" "testbuc04" {
  bucket = "shruti0012389"
  acl    = "public-read"
provisioner "local-exec" {
   command ="git clone https://github.com/shruti004/task-1/blob/master/Screenshot_20190906-093636%20(1).png"
}
tags ={
Name = "s3bucket"
}
}
resource "aws_s3_bucket_object" "object24" {
  bucket = "${aws_s3_bucket.testbuc04.id}"
  key    = "Screenshot_20190906-093636 (1)_pic.png"
  source = "C:/Users/Shruti/Downloads/task-1-master/Screenshot_20190906-093636 (1).png"

content_type ="image/png"
  
}
locals {
  s3_origin_id = "aws_s3_bucket.testbuc04.id"
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Some comment"
}
resource "aws_cloudfront_distribution" "s3distributiontask" {
  origin {
    domain_name = "aws_s3_bucket.testbuc04.bucket.s3.amazonaws.com"
    origin_id   =  local.s3_origin_id
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 Web Distribution"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "aws_s3_bucket.testbuc04.id"


    forwarded_values {
      query_string = false


      cookies {
        forward = "none"
      }
    }


    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
      
    }
  }


  tags = {
    Name        = "Web-CF-Distribution"
    Environment = "Production"
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }
 connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/Shruti/Downloads/mytest24.pem")
    host     = aws_instance.osinstance24.public_ip
  }
provisioner "remote-exec" {
    inline = [
                    "sudo su <<EOF",
                      "echo \"<img src= http://${aws_cloudfront_distribution.s3distributiontask.domain_name}/${aws_instance.osinstance24.public_ip}/web.html"
                      
]
}

depends_on = [
     aws_cloudfront_distribution.s3distributiontask,
   ]
provisioner "local-exec" {
	    command  = "cd C:/Program Files/Google/Chrome/Application/${aws_instance.osinstance24.public_ip}/web.html"
  

}
}
