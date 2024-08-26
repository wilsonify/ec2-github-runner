

deploy:
	terraform init && \
	terraform plan && \
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

setup:
	# update address in inventory file
	ansible-playbook -i inventory.ini setup-runner-playbook.yaml
	# add token into /etc/environment and reboot


