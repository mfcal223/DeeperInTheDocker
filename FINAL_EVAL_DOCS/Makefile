NAME        = inception
COMPOSE     = docker compose -f srcs/docker-compose.yml
DATA_PATH   = /home/mcalciat/data
DOCKER_DIR  = $(DATA_PATH)/docker

all: up

up: create_dirs
	$(COMPOSE) up --build -d

build: create_dirs
	$(COMPOSE) build

down:
	$(COMPOSE) down

start: create_dirs
	$(COMPOSE) up -d

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs

ps:
	$(COMPOSE) ps

create_dirs:
	@echo "Preparing Docker data directory..."
	mkdir -p $(DOCKER_DIR)
	sudo mkdir -p $(DOCKER_DIR)/tmp
	sudo chown -R $(USER):$(USER) $(DATA_PATH)

clean: 
	$(COMPOSE) down -v

fclean: 
	$(COMPOSE) down -v --rmi all
	sudo systemctl restart docker
	
	
re: fclean up

.PHONY: all up build down start stop restart logs ps create_dirs clean fclean re
