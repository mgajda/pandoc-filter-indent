#!/bin/bash

build() {
  FILTER_EXE=$(stack path --local-install-root)/bin/pandoc-filter-indent;
  stack build && \
  stack run text < test/example.json > out.json &&
  echo "Filter is ${FILTER_EXE}" &&
  pandoc -f json -t markdown  out.json -o out.md &&
  pandoc              -t plain test/example.md -o out.txt     --filter "${FILTER_EXE}"                                          &&
  pandoc              -t html  test/example.md -o out.html    --filter "${FILTER_EXE}"                                          &&
  pandoc --standalone -t latex test/example.md -o out.tex     --filter "${FILTER_EXE}"                                          &&
  pandoc              -t pdf   test/example.md -o out.pdf     --filter "${FILTER_EXE}"                                          &&
  pandoc --standalone -t latex test/example.md -o out-acm.tex --filter "${FILTER_EXE}" --template acm-template/new-template.tex &&
  pandoc --standalone -t pdf   test/example.md -o out-acm.pdf --filter "${FILTER_EXE}" --template acm-template/new-template.tex &&
  cat out.md
}

build
if [ "$1" == "--watch" ]; then 
  while inotifywait src/*.hs app/*.hs src/*/*.hs; do
    build;
  done;
fi;

