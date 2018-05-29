terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    bucket  = "gds-re-aws-elasticsearch-spike"
    key     = "elasticsearch.tfstate"
    encrypt = true
    region  = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "template_file" "logstash_elasticsearch_policy" {
  template = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "es:ESHttp*"
            ],
            "Resource": "$${es_arn}/*"
        }
    ]
}
POLICY
  vars {
    es_arn = "${aws_elasticsearch_domain.elk_spike.arn}"
  }
}

resource "aws_elasticsearch_domain" "elk_spike" {
  domain_name           = "gds-elk-spike"
  elasticsearch_version = "6.2"

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 500
  }

  cluster_config {
    instance_type  = "m4.large.elasticsearch"
    instance_count = 3
  }
}

resource "aws_iam_user" "logstash" {
  name = "logstash"  
}

resource "aws_iam_access_key" "logstash" {
  user = "${aws_iam_user.logstash.name}"
}

resource "aws_iam_user_policy" "logstash_elasticsearch" {
  name = "logstash_elasticsearch_access"
  user = "${aws_iam_user.logstash.name}"
  policy = "${data.template_file.logstash_elasticsearch_policy.rendered}"
}

output "domain" {
  value = "${aws_elasticsearch_domain.elk_spike.endpoint}"
}

output "kibana" {
  value = "${aws_elasticsearch_domain.elk_spike.kibana_endpoint}"
}

output "logstash_access_key" {
  value = "${aws_iam_access_key.logstash.id}"
}

output "logstash_secret_key" {
  value = "${aws_iam_access_key.logstash.secret}"
}
