NAME = inception
SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml

# Host data paths for volume persistence
DATA_PATH = /home/cwong/data
WP_DATA = $(DATA_PATH)/wordpress
DB_DATA = $(DATA_PATH)/mariadb

all: up

up: build
	@printf "Launching $(NAME) containers...\n"
	@docker compose -f $(COMPOSE_FILE) up -d

build: volumes
	@printf "Building $(NAME) images...\n"
	@docker compose -f $(COMPOSE_FILE) build

volumes:
	@printf "Creating local host volume directories...\n"
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)

down:
	@printf "Stopping $(NAME) containers...\n"
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@printf "Cleaning up $(NAME) containers and networks...\n"
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v

fclean: clean
	@printf "Deep cleaning: Removing persistent host data volumes...\n"
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up build volumes down clean fclean re
