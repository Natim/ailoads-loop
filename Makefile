HERE = $(shell pwd)
BIN = $(HERE)/bin
PYTHON = $(BIN)/python3.4

INSTALL = $(BIN)/pip install


.PHONY: all test build

all: build test

$(PYTHON):
	pyvenv $(VTENV_OPTS) .

init:
	sed -i "s/LOOP_FXA_USER_SALT=[a-zA-Z0-9_-]*/LOOP_FXA_USER_SALT=`python -c 'import os, base64; print(base64.urlsafe_b64encode(os.urandom(36)))'`/g" loop.json

build: $(PYTHON)
	$(BIN)/pip install requests requests_hawk PyFxA
	$(BIN)/pip install https://github.com/tarekziade/ailoads/archive/master.zip


test: build
	$(BIN)/pip install flake8 tox
	$(BIN)/flake8 ailoads
	$(BIN)/tox

build_docker:
	docker build -t loop/loadtest .

run_docker:
	docker run -e LOOP_DURATION=30 -e LOOP_NB_USERS=4 loop/loadtest
