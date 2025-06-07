# Defina isso para ~usar em todos os lugares na configuração do projeto
VERSÃO_PYTHON ?= 3.8.10
# os diretórios que contêm os módulos de biblioteca que este repositório constrói
LIBRARY_DIRS = minhabiblioteca
# construir artefatos organizados neste Makefile
BUILD_DIR ?= construir

# Opções do PyTest
PYTEST_HTML_OPTIONS = --html= $( BUILD_DIR ) /report.html --self-contained-html
PYTEST_TAP_OPTIONS = --tap-combined --tap-outdir $( BUILD_DIR )
OPÇÕES_DE_COBERTURA_DE_TESTE_PY = --cov= $( DISTRITOS_DE_BIBLIOTECA )
OPÇÕES_DE_TESTE_PY ?= $( OPÇÕES_HTML_DE_TESTE )  $( OPÇÕES_DE_TAP_DE_TESTE )  $( OPÇÕES_DE_COBERTURA_DE_TESTE_PY )

# Opções de verificação de tipo MyPy
MYPY_OPTS ?= --python-versão $( nome base  $( PYTHON_VERSION ) ) --show-column-numbers --pretty --html-report $( BUILD_DIR ) /mypy
# Artefatos de instalação do Python
PYTHON_VERSION_FILE =.python-version
ifeq ( $( shell qual pyenv) ,)
# pyenv não está instalado, adivinhe o caminho final FWIW
PYENV_VERSION_DIR ?= $( HOME ) /.pyenv/versions/ $( PYTHON_VERSION )
outro
# pyenv está instalado
PYENV_VERSION_DIR ?= $( shell pyenv root) /versões/ $( PYTHON_VERSION )
fim se
PIP ?= pip3

POESIA_OPTS ?=
POESIA ?= poesia $( POESIA_OPÇÕES )
RUN_PYPKG_BIN = $( POESIA ) executar

COR_LARANJA = \033[33m
REINICIALIZAÇÃO_DE_CORES = \033[0m

# #@ Utilitário

.PHONY : ajuda
ajuda :   # # Exibir esta ajuda
	@awk ' BEGIN {FS = ":.*##"; printf "\nUso:\n make \033[36m\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } '  $( MAKEFILE_LIST )

.PHONY : versão-python
version-python : # # Ecoa a versão do Python em uso
	@echo $( VERSÃO_PYTHON )

# #@ Teste

.PHONY : teste
teste : # # Executa testes
	$( RUN_PYPKG_BIN ) pytest \
		$( OPÇÕES_DE_TESTE_PY )  \
		testes/ * .py

# #@ Construção e Publicação

.PHONY : construir
build : # # Executa uma compilação
	$( POESIA ) construir

.PHONY : publicar
publicar : # # Publicar uma compilação no repositório configurado
	$( POESIA ) publicar $( POESIA_PUBLISH_OPTIONS_SET_BY_CI_ENV )

.PHONY : deps-py-update
deps-py-update : pyproject.toml # # Atualizar dependências de Poesia, por exemplo, após adicionar uma nova manualmente
	Atualização de $( POESIA )

# #@ Configurar
# detecção dinâmica do diretório de instalação do Python com pyenv
$( PYENV_VERSION_DIR ) :
	pyenv install --skip-existing $( PYTHON_VERSION )
$( ARQUIVO_VERSÃO_PYTHON ) : $( DIR_VERSÃO_PYENV )
	pyenv local  $( PYTHON_VERSION )

.PHONY : dependências
deps : deps-brew deps-py   # # Instala todas as dependências

.PHONY : deps-brew
deps-brew : Brewfile # # Instala dependências de desenvolvimento do Homebrew
	pacote de preparação --file=Brewfile
	@echo " $( COLOR_ORANGE ) Certifique-se de que o pyenv esteja configurado no seu shell. $( COLOR_RESET ) "
	@echo " $( COLOR_ORANGE ) Deveria ter algo como 'eval \$ $( pyenv init - ) ' $( COLOR_RESET ) "

.PHONY : deps-py
deps-py : $( PYTHON_VERSION_FILE )  # # Instala dependências de desenvolvimento e tempo de execução do Python
	$( PIP ) instalar --upgrade \
		--index-url $( PYPI_PROXY )  \
		pip
	$( PIP ) instalar --upgrade \
                                     		--index-url $(PYPI_PROXY) \
                                     		poesia
	$(POESIA) instalar

# #@ Qualidade do Código

.PHONY : verifique
check : check-py # # Executa linters e outras ferramentas importantes

.PHONY : check-py
check-py : check-py-flake8 check-py-black check-py-mypy # # Verifica apenas arquivos Python

.PHONY : check-py-flake8
check-py-flake8 : # # Executa o linter flake8
	$( RUN_PYPKG_BIN ) flake8 .

.PHONY : check-py-black
check-py-black : # # Executa preto no modo de verificação (sem alterações)
	$( RUN_PYPKG_BIN ) preto --check --line-length 118 --fast .

.PHONY : verifique-py-mypy
check-py-mypy : # # Executa mypy
	$( RUN_PYPKG_BIN ) mypy $( MYPY_OPTS )  $( LIBRARY_DIRS )

.PHONY : formato-py
format-py : # # Executa em preto, faz alterações onde necessário
	$( RUN_PYPKG_BIN ) preto .

.PHONY : formato-autopep8
formato-autopep8 :
	$( RUN_PYPKG_BIN ) autopep8 --in-place --recursive .

.PHONY : formato-isort
formato-isort :
	$( RUN_PYPKG_BIN ) isort --recursivo .