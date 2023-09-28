

.PHONY: init
init: check-platform
	terraform -chdir=main-$(platform) init


.PHONY: plan
plan: check-platform check-cluster init
	terraform -chdir=main-$(platform) \
	plan \
	-state=../clusters/$(platform)/$(cluster)/terraform.tfstate \
	-var-file=../clusters/$(platform)/$(cluster)/inputs.tfvars \
	-var 'cluster_name=$(cluster)'


.PHONY: apply
apply: check-platform check-cluster init
	terraform -chdir=main-$(platform) \
	apply \
	-state=../clusters/$(platform)/$(cluster)/terraform.tfstate \
	-var-file=../clusters/$(platform)/$(cluster)/inputs.tfvars \
	-var 'cluster_name=$(cluster)'





.PHONY: check-cluster
check-cluster:
ifndef cluster
	$(error "cluster" is undefined, Please set "cluster")
endif
	@ls clusters/$(platform) | sort | grep -q "^$(cluster)$$" || (echo "\"$(cluster)\" not found in clusters folder"; exit 1)

.PHONY: check-platform
check-platform:
ifndef platform
	$(error "platform" is undefined, Please set "platform", valid values are: aws, gcp)
endif
	@echo "aws gcp" | grep -w -q "$(platform)" || (echo "\"platform\" invalid, valid values are: aws, gcp"; exit 1)


.PHONY: help
help:
	@echo "This Makefile is thin wrapper for Terraform to easily provision and manage multiple Mrissa clusters"
	@echo
	@echo "Syntax: make action param1=value1 param2=value2, ..."
	@echo
	@echo "params:"
	@echo "platform    cloud platform: aws, gcp"
	@echo "cluster     Mrissa cluster"
	@echo
	@echo "actions:"
	@echo "plan         params: cluster,platform    help: terraform plan wrapper"
	@echo "apply        params: cluster,platform    help: terraform apply wrapper"
	@echo "destroy      params: cluster,platform    help: terraform destroy wrapper"
