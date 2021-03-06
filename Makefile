include make.env

# Default values for build docker images
VERSION ?= latest-dev
IMAGE_NAME ?= ll-app

configure: docker-compose.yml.template
	sed "s/DOCKER_ID_PLACEHOLDER/${DOCKER_ID}/g" docker-compose.yml.template > docker-compose.yml

build-common: configure ll-app/.env.template
	docker build --target common \
		--build-arg app_secret=${APP_SECRET} \
		--build-arg domain_name=${DOMAIN_NAME} \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-common:$(VERSION) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-common:$(VERSION_NUM) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-common:latest \
		-f ll-app/Dockerfile ./ll-app/

build-ui: build-common
	docker build --target ui \
		--build-arg app_secret=${APP_SECRET} \
		--build-arg domain_name=${DOMAIN_NAME} \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-ui:$(VERSION) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-ui:$(VERSION_NUM) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-ui:latest \
		-f ll-app/Dockerfile ./ll-app/

build-worker: build-common
	docker build --target worker \
		--build-arg app_secret=${APP_SECRET} \
		--build-arg domain_name=${DOMAIN_NAME} \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-worker:$(VERSION) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-worker:$(VERSION_NUM) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-worker:latest \
		-f ll-app/Dockerfile ./ll-app/

build-api: build-common
	docker build --target api \
		--build-arg app_secret=${APP_SECRET} \
		--build-arg domain_name=${DOMAIN_NAME} \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-api:$(VERSION) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-api:$(VERSION_NUM) \
		-t $(DOCKER_ID)/$(IMAGE_NAME)-api:latest \
		-f ll-app/Dockerfile ./ll-app/

build-app: build-ui build-worker build-api

build-nginx: ll-nginx/Dockerfile ll-nginx/nginx.conf.template
	docker build \
		-t $(DOCKER_ID)/ll-nginx:$(VERSION) \
		-t $(DOCKER_ID)/ll-nginx:$(VERSION_NUM) \
		-t $(DOCKER_ID)/ll-nginx:latest \
		-f ll-nginx/Dockerfile ./ll-nginx/

build-all: build-nginx build-ui build-worker build-api

first-launch: build-all
	docker-compose up -d
	docker-compose exec api node cli/dist/server createSiteAdmin \
		${ADMIN_CREDENTIALS_EMAIL} ${ADMIN_CREDENTIALS_ORGANISATION} \
		${ADMIN_CREDENTIALS_PASSWORD}