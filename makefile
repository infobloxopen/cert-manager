sync: submodule-update
	cd upstream/cert-manager &&	git fetch && git reset --hard ${APP_VERSION}
	rm -rf stable/*
	mkdir -p stable
	cp -vr upstream/cert-manager/deploy/charts/cert-manager/ stable/
	cp -vr upstream/cert-manager/deploy/crds stable/cert-manager

submodule-update:
	git submodule update --init --remote upstream/cert-manager

submodule:
	git submodule add --name upstream/cert-manager https://github.com/jetstack/cert-manager

PATCHES := $(sort $(wildcard *.patch))


makepatch:
	git add -A stable/cert-manager
	git diff --cached > next.patch

patch: $(PATCHES)

%.patch: $(shell find stable/cert-manager -type f)
	git apply $@
	touch $@

package:
	helm package stable/cert-manager --version ${APP_VERSION} --app-version ${APP_VERSION}
	rm -rf stable/
	mv -v cert-manager-${APP_VERSION}.tgz docs

repo-index:
	helm repo index docs --url https://infobloxopen.github.io/cert-manager/

git-config:
	@if ! git config user.email ; then\
		git config user.email "dwells@infoblox.com"; \
	fi
	@if ! git config user.name ; then\
		git config user.name "Github Actions"; \
	fi

release: git-config package repo-index

update-index: git-config
	if ! git rev-parse ${APP_VERSION} >/dev/null 2>&1 ; then\
		git add .; \
		git commit -m "updated index for ${APP_VERSION} fixes #${TICKET}"; \
		git tag -a ${APP_VERSION} -m "${APP_VERSION} release"; \
		git push origin master --tags; \
	fi
