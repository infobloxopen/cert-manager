sync:
	cd upstream/cert-manager &&	git checkout v0.13.1
	cp -vr upstream/cert-manager/deploy/charts/cert-manager/ stable/cert-manager/

submodule-update:
	git submodule update --remote upstream/cert-manager

submodule:
	git submodule add --name upstream/cert-manager https://github.com/jetstack/cert-manager

PATCHS := 01-crds.patch

makepatch:
	git add -A stable/cert-manager
	git diff --cached > 01-crds.patch

patch: $(PATCHS)

%.patch: $(shell find stable/cert-manager -type f)
	git apply $@
	touch $@
