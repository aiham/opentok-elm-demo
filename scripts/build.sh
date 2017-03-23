#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

elm-make "${DIR}/app.elm" --warn "--output=${DIR}/compiled/app.js"
