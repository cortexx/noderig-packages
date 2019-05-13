REMOTE_REF := "https://github.com/ovh/noderig.git"
VERSION    ?= $(shell make get-last-release)
BUILD_DIR  := $(HOME)/go/src/github.com/ovh/noderig
OUTPUT     := ./package

help: ## Show help message to user
	@ echo 'Usage: make [target] [VARIABLE]'
	@ echo ''
	@ echo '- To list all the available tags for the Noderig project:   `make list-releases`'
	@ echo '- To list the latest tag available for the Noderig project: `make get-last-release`'
	@ echo '- To build a specific release:                              `make build VERSION=$${RELEASE}`'
	@ echo '- To build the latest release by default:                   `make build`'
	@ echo '- To build a .deb or a .rpm package:                        `make deb || make rpm`'

list-releases: ## List all tags available for the noderig repository
	@ git ls-remote --tags "$(REMOTE_REF)" | awk -F '/' '{ print $$3|"sort -n" }'

get-last-release: ## Get the latest tag available for the noderig repository
	@ git ls-remote --tags "$(REMOTE_REF)" | awk -F '/' '{ print $$3|"sort -n| tail -n 1" }' 

.PHONY: build
build: clean ## Clean workspace and build a new release of the Noderig project
ifndef VERSION
	$(error VERSION is not set)
endif
	mkdir -p "$(BUILD_DIR)" "$(OUTPUT)"
	git clone -b "$(VERSION)" --single-branch --depth 1 "$(REMOTE_REF)" "$(BUILD_DIR)"
	cd "$(BUILD_DIR)"; make glide-install; make release
	mv "$(BUILD_DIR)/build/noderig" "$(OUTPUT)"

.PHONY: deb
deb: ## Build a Debian package
	rm -f noderig*.deb
	fpm -m "<kevin@d33d33.fr>" \
		--description "Sensision exporter for OS metrics" \
		--url "https://github.com/ovh/noderig" \
		--license "BSD-3-Clause" \
		--version $(shell echo $$(./build/noderig version | awk '{print $$2}')-$$(lsb_release -cs)) \
		-n noderig \
		-d logrotate \
		-s dir -t deb \
		-a all \
		--deb-user noderig \
		--deb-group noderig \
		--deb-no-default-config-files \
		--config-files /etc/noderig/config.yaml \
		--deb-init deb/noderig.init \
		--directories /opt/noderig \
		--directories /var/log/noderig \
		--before-install deb/before-install.sh \
		--after-install deb/after-install.sh \
		--before-upgrade deb/before-upgrade.sh \
		--after-upgrade deb/after-upgrade.sh \
		--before-remove deb/before-remove.sh \
		--after-remove deb/after-remove.sh \
		--inputs deb/input

.PHONY: rpm
rpm: ## Build a RPM package
	rm -f noderig*.rpm
	mkdir -p opt/noderig
	fpm -m "<kevin@d33d33.fr>" \
		--description "Sensision exporter for OS metrics" \
		--url "https://github.com/ovh/noderig" \
		--license "BSD-3-Clause" \
		--version $(shell echo $$(./build/noderig version | awk '{print $$2}')) \
		-n noderig \
		-d logrotate \
		-s dir -t rpm \
		-a all \
		--rpm-user noderig \
		--rpm-group noderig \
		--config-files /etc/noderig/config.yaml \
		--rpm-init rpm/noderig.init \
		--before-install rpm/before-install.sh \
		--after-install rpm/after-install.sh \
		--before-upgrade rpm/before-upgrade.sh \
		--after-upgrade rpm/after-upgrade.sh \
		--before-remove rpm/before-remove.sh \
		--after-remove rpm/after-remove.sh \
		--inputs rpm/input \
		--rpm-auto-add-directories opt/noderig/

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(OUTPUT)
	rm -rf opt
	rm -f *.deb
	rm -f *.rpm
