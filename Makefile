SHELL=/bin/bash

list-lambda-test:
	cd backend/list-s3-items; go test ./...;

list-lambda-build:
	cd backend/list-s3-items; CGO_ENABLED=0  GOOS=linux GOARCH=amd64 go build -o ../../bootstrap




list-lambda-plan:
	set -a; source .env; cd backend/list-s3-items/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_LIST_LAMBDA" \
        -backend-config="region=eu-west-3"; \
		terraform plan

list-lambda-apply:
	set -a; source .env; cd backend/list-s3-items/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_LIST_LAMBDA" \
        -backend-config="region=$$TF_BACKEND_REGION"; \
		terraform apply

api-gw-plan:
	set -a; source .env;  cd backend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init -reconfigure \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_API_GW" \
        -backend-config="region=$$TF_BACKEND_REGION"; \
		terraform plan

api-gw-apply:
	set -a; source .env; cd backend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_API_GW" \
        -backend-config="region=$$TF_BACKEND_REGION"; \
		terraform apply

api-gw-output:
	set -a; source .env; cd backend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_API_GW" \
        -backend-config="region=$$TF_BACKEND_REGION"; \
		terraform output

api-gw-test:
	curl -X GET \
	  -H "x-api-key: YOUR_API_KEY" \
	  -H "Content-Type: application/json" \
	  -d '{"bucket":"my-bucket-name","key":"optional/prefix/"}' \
	  https://x3xecogfjg.execute-api.eu-west-3.amazonaws.com/prod/list-s3



list-lambda-prod-logs:
	cd hardcoded-makefile-do-not-git; make list-lambda-prod-logs

api-gw-test-direct:
	cd hardcoded-makefile-do-not-git; make api-gw-test-direct


api-gw-test-curl:
	cd hardcoded-makefile-do-not-git; make api-gw-test-curl