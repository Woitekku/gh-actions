resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)
  image_scanning_configuration {
    scan_on_push = true
  }
  name = format("%s-%s", var.account_name, each.value)

  tags = {
    Name = format("%s-%s", var.account_name, each.value)
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = toset(var.repositories)
  repository = aws_ecr_repository.this[each.value].name

  policy = <<EOF
{
    "rules": [
        {
          "rulePriority" : 1,
          "description" : "Keep latest image",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["latest"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 5 images starting with 'prd.'",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["prd."],
            "countType" : "imageCountMoreThan",
            "countNumber" : 5
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
            "rulePriority": 3,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}