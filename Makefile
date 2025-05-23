TITLE = Flarum Docker container tasks
SHELL = /bin/bash
THIS = $(lastword $(MAKEFILE_LIST))
# the "main" container
DEFAULTCONTAINER = $(if $(CONTAINER),$(CONTAINER),web)
IFCONTAINER = $(if $(CONTAINER),$(CONTAINER))

help:  # prints this help
	@perl -e "$$AUTOGEN_HELP_PL" $(THIS)

up: serve
start: serve
serve:  # (aliases: up, start) start the Flarum containers [try DETACH=1, REBUILD=1]
	docker compose up$(if $(DETACH), --detach)$(if $(BUILD)$(REBUILD), --build) $(IFCONTAINER)

down: stop
stop:  # (alias: down) stop the Flarum containers
	docker compose down $(IFCONTAINER)

restart:  # restart the containers
	$(MAKE) -f $(THIS) down
	$(MAKE) -f $(THIS) up

log: logs
tail: logs
logs:  # (aliases: log, tail) check container logs [try FOLLOW=1, CONTAINER=]
	docker compose logs$(if $(FOLLOW), --follow) $(IFCONTAINER)

sh: shell
shell:  # (alias: sh) start a shell in the container [try CONTAINER=db]
	docker compose exec $(DEFAULTCONTAINER) sh

superclean:  # (DESTRUCTIVE) remove all container volumes and start over
	@echo; \
	read -ep 'REALLY remove all data -- including the database -- and start over? [y/N] '; \
	if [[ $$REPLY =~ ^[YyJj] ]]; then \
		$(MAKE) .superclean; \
	else \
		echo "Okay, not removing anything."; \
	fi

.superclean:
	-sudo rm -r assets extensions storage nginx db

##
##  internals you can safely ignore
##
define AUTOGEN_HELP_PL
# line XXX
    if (-t 1) {
        $$UL = "\e[0;4m"; $$BOLDBLUE = "\e[1m\e[1;34m"; $$RESET = "\e[0m";
    }
    $$max = 0;
    @targets = ();
    print "\n  ", $$UL, "Makefile targets - $(TITLE)", $$RESET, "\n\n";
    while (<>) {
        push @targets, [$$1, $$2] if /^(\w.+):[^=].*#\s*(.*)/;
        $$max = length($$1) if length($$1) > $$max;
    }
    foreach (@targets) {
        printf "    %smake %-$${max}s%s    %s\n", $$BOLDBLUE, @$$_[0], $$RESET, @$$_[1];
    }
    print "\n";
endef
export AUTOGEN_HELP_PL

# vim: sw=4 ts=4 noet indentexpr= indentkeys=
