

deploy:
	terraform init && terraform plan && terraform apply -auto-approve

setup:
	ansible-playbook -i inventory.ini setup-runner-playbook.yaml

