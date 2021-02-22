# [Elixir - Teoría del Lenguaje [75.31]](https://youtu.be/Oy4rFTgthkQ)
[![Build Status](https://travis-ci.com/jian01/tp-elixir-tdl.svg?branch=master)](https://travis-ci.com/jian01/tp-elixir-tdl)

## Descripción :book:
Trabajo práctico final de investigación y utilización del lenguaje de programación **Elixir**, desarrollado para la materia **Teoría del Lenguaje** (75.31) de la Facultad de Ingeniería de la Universidad de Buenos Aires.

## [Presentación final](https://youtu.be/Oy4rFTgthkQ) :movie_camera: 

## Integrantes :busts_in_silhouette:
| Nombre | Apellido | Padrón | Mail |
|--------|----------|--------|------|
| Gianmarco | Cafferata | 99423 | gcafferata@fi.uba.ar |
| Lautaro | Manzano | 100274 | lmanzano@fi.uba.ar |
| Matías | Scakosky | 99627 | mscakosky@fi.uba.ar |
| Mauro | Parafati | 102749 | mparafati@fi.uba.ar |

## Requisitos :ballot_box_with_check:
Se listan a continuación los requisitos necesarios para poder correr el proyecto:

* [Erlang VM y Elixir.](https://elixir-lang.org/install.html)
* Mix *(incluído en la instalación de Elixir)*.
* [Python3](https://www.python.org/downloads/)
* GNU Make. (`sudo apt install make`)

## Uso :computer:
Se detalla a continuación una breve explicación para correr los distintos módulos del proyecto, así como para correr las pruebas de integración.

### Servidor

1. `cd chatserver` para situarnos en el directorio del servidor.
2. Instalar las dependencias: `mix deps.get`
3. Correr el servidor según el modo deseado:
  * Modo normal: `mix run --no-halt`
  * Modo interactivo: `iex -S mix` *(útil para monitoreo utilizando `:observer.start` dentro de Elixir)*

### Cliente

1. `cd python_client` para situarnos en el directorio del cliente.
2. Correr el cliente gráfico con `python3 gui_client <port> <ip> <id>` *(<id> representa el id con el que queremos entrar al chat).*

*Obs.: Puede que sea necesario instalar paquetes de Python con pip.*

### Pruebas
El proyecto cuenta con tests de integración escritos en Python, para correr los mismos:

1. Correr `make test`
2. Profit 🤑🔥

*Obs.: puede que sea necesario modificar el `Makefile` para cambiar `python` por `python3`, dependiendo de cómo tengas instalado Python en tu sistema.*
