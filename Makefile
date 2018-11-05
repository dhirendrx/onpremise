REPOSITORY?=sentry-onpremise
TAG?=latest

OK_COLOR=\033[32;01m
NO_COLOR=\033[0m

build:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Building $(REPOSITORY):$(TAG)"
	@docker build --rm -t $(REPOSITORY):$(TAG) .

$(REPOSITORY)_$(TAG).tar: build
	@echo "$(OK_COLOR)==>$(NO_COLOR) Saving $(REPOSITORY):$(TAG) > $@"
	@docker save $(REPOSITORY):$(TAG) > $@

push: build
	@echo "$(OK_COLOR)==>$(NO_COLOR) Pushing $(REPOSITORY):$(TAG)"
	@docker push $(REPOSITORY):$(TAG)

start: build
	@echo "$(OK_COLOR)==>$(NO_COLOR) Removing existing containers of $(REPOSITORY):$(TAG)"
	@docker rm sentry-web || true
	@docker rm sentry-worker || true
	@docker rm sentry-cron || true
	@echo "$(OK_COLOR)==>$(NO_COLOR) Staring Web $(REPOSITORY):$(TAG)"
	@docker run --detach --env-file .env --name sentry-web --publish 9000:9000 $(REPOSITORY) run web
	@echo "$(OK_COLOR)==>$(NO_COLOR) Staring Worker $(REPOSITORY):$(TAG)"
	@docker run --detach --env-file .env --name sentry-worker $(REPOSITORY) run worker
	@echo "$(OK_COLOR)==>$(NO_COLOR) Staring Cron $(REPOSITORY):$(TAG)"
	@docker run --detach --env-file .env --name sentry-cron $(REPOSITORY) run cron

stop:
	@echo "$(OK_COLOR)==>$(NO_COLOR) Stop running containers of $(REPOSITORY):$(TAG)"
	@docker stop sentry-web || true
	@docker stop sentry-worker || true
	@docker stop sentry-cron || true

.PHONY: start stop build push
