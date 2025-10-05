SHELL=/bin/bash

list-lambda-build:
	cd backend/list-s3-items; CGO_ENABLED=0  GOOS=linux GOARCH=amd64 go build -o bootstrap

presign-lambda-build:
	cd backend/presign-url; CGO_ENABLED=0  GOOS=linux GOARCH=amd64 go build -o bootstrap


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


presign-lambda-plan:
	set -a; source .env; cd backend/presign-url/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_PRESIGN_LAMBDA" \
        -backend-config="region=eu-west-3"; \
		terraform plan

presign-lambda-apply:
	set -a; source .env; cd backend/presign-url/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
        -backend-config="bucket=$$TF_BACKEND_BUCKET" \
        -backend-config="key=$$TF_BACKEND_KEY_PRESIGN_LAMBDA" \
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


frontend-plan:
	set -a; source .env; cd frontend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
		-backend-config="bucket=$$TF_BACKEND_BUCKET" \
		-backend-config="key=$$TF_BACKEND_KEY_FRONTEND_SITE" \
		-backend-config="region=$$TF_BACKEND_REGION"; \
		terraform plan

frontend-apply:
	set -a; source .env; cd frontend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
		-backend-config="bucket=$$TF_BACKEND_BUCKET" \
		-backend-config="key=$$TF_BACKEND_KEY_FRONTEND_SITE" \
		-backend-config="region=$$TF_BACKEND_REGION"; \
		terraform apply


frontend-output:
	set -a; source .env; cd frontend/infra/production; export AWS_PROFILE=eniltrex-terraform; terraform init \
		-backend-config="bucket=$$TF_BACKEND_BUCKET" \
		-backend-config="key=$$TF_BACKEND_KEY_FRONTEND_SITE" \
		-backend-config="region=$$TF_BACKEND_REGION"; \
		terraform output

presign-lambda-logs:
	cd hardcoded-makefile-do-not-git; make presign-lambda-prod-logs

list-lambda-logs:
	cd hardcoded-makefile-do-not-git; make list-lambda-prod-logs

list-lambda-test-lambda:
	cd hardcoded-makefile-do-not-git; make list-lambda-test-lambda

presign-lambda-test-lambda:
	cd hardcoded-makefile-do-not-git; make presign-lambda-test-lambda

list-lambda-api-gw-test-direct:
	cd hardcoded-makefile-do-not-git; make list-lambda-api-gw-test-direct

presign-lambda-api-gw-test-direct:
	cd hardcoded-makefile-do-not-git; make presign-lambda-api-gw-test-direct


list-lambda-api-gw-test-curl:
	cd hardcoded-makefile-do-not-git; make list-lambda-api-gw-test-curl

presign-lambda-api-gw-test-curl:
	cd hardcoded-makefile-do-not-git; make presign-lambda-api-gw-test-curl

frontend-cf-logs:
	cd hardcoded-makefile-do-not-git; make cf-logs