#!/bin/sh
find src | entr elm make src/Main.elm --debug
