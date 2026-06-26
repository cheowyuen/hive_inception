SRCS_DIR = srcs
COMPOSE_FILE = $(SRCS_DIR)/docker-compose.yml
ENV_FILE = $(SRCS_DIR)/.env
DATA_PATH = /home/cwong/data
WP_DATA = $(DATA_PATH)/wordpress
DB_DATA = $(DATA_PATH)/mariadb

all: up

up: volumes
	@docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE) up -d --build

volumes:
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)

down:
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v
	@docker system prune -a -f

fclean: clean
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all up volumes down clean fclean re
