.PHONY: run
run:
	iex -S mix phx.server

.PHONY: docker-build
docker-build:
	docker build -t bao:latest .