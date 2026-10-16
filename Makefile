.PHONY: backend secrets init plan apply destroy vault-edit

# Локальное S3-хранилище стейта (MinIO вместо Yandex Object Storage)
backend:
	docker start minio-tfstate 2>/dev/null || docker run -d --name minio-tfstate -p 9000:9000 \
		-e MINIO_ROOT_USER=$$AWS_ACCESS_KEY_ID -e MINIO_ROOT_PASSWORD=$$AWS_SECRET_ACCESS_KEY \
		-e MINIO_DEFAULT_BUCKETS=tfstate -v minio-tfstate:/bitnami/minio/data bitnamilegacy/minio

secrets:
	ansible-playbook ansible/secrets.yml

init: secrets
	cd terraform && TF_CLI_CONFIG_FILE=.terraformrc terraform init

plan: secrets
	cd terraform && terraform plan

apply: secrets
	cd terraform && terraform apply

destroy: secrets
	cd terraform && terraform destroy

vault-edit:
	ansible-vault edit ansible/vault.yml
