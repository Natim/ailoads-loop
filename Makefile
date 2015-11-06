HERE = $(shell pwd)
BIN = $(HERE)/venv/bin
PYTHON = $(BIN)/python3.4

INSTALL = $(BIN)/pip install

LOOP_FXA_USER_SALT = 0EvBb1DFqPkgrSruK8qYxeSE-FNMvwxBagbSSqq8w-v6gL7g

.PHONY: all test build

all: build test

$(PYTHON):
	$(shell basename $(PYTHON)) -m venv $(VTENV_OPTS) venv
	$(BIN)/pip install requests requests_hawk PyFxA flake8
	$(BIN)/pip install https://github.com/tarekziade/ailoads/archive/master.zip
build: $(PYTHON)

init:
	sed -i "s/LOOP_FXA_USER_SALT=[a-zA-Z0-9_-]*/LOOP_FXA_USER_SALT=`python -c 'import os, base64; print(base64.urlsafe_b64encode(os.urandom(36)))'`/g" loop.json

test: build
	$(BIN)/flake8 loadtest.py
	LOOP_FXA_USER_SALT=$(LOOP_FXA_USER_SALT) $(BIN)/ailoads -v -d 30

clean:
	rm -fr venv/ __pycache__/

docker-build:
	docker build -t loop/loadtest .

docker-run:
	docker run -e LOOP_DURATION=30 -e LOOP_NB_USERS=4 loop/loadtest
