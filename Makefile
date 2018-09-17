BUILD_DIR=./build

.PHONY: build
build: clean
	mkdir -p $(BUILD_DIR)
	wget -P $(BUILD_DIR) https://github.com/ovh/noderig/archive/v$(VERSION).zip
	unzip -q -d $(BUILD_DIR) $(BUILD_DIR)/v$(VERSION).zip
	cd $(BUILD_DIR)/noderig-$(VERSION) && glide install
	cd $(BUILD_DIR)/noderig-$(VERSION) && make release
	mv $(BUILD_DIR)/noderig-$(VERSION)/build/noderig $(BUILD_DIR)/

.PHONY: deb
deb:
	rm -f noderig*.deb
	fpm -m "<kevin@d33d33.fr>" \
		--description "Sensision exporter for OS metrics" \
		--url "https://github.com/ovh/noderig" \
		--license "BSD-3-Clause" \
		--version $(shell echo $$(./build/noderig version | awk '{print $$2}')-$$(lsb_release  -cs)) \
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
rpm:
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
	rm -rf build
	rm -rf opt
	rm -f *.deb
	rm -f *.rpm
