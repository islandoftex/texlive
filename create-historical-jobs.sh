#!/bin/bash

year=$((`date +%Y`-1))
while [ $year -gt 2013 ]
do
		echo "`cat <<EOF
build:historic:$year:
  stage: build
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "no"
    SRCFILES: "no"
  <<: *historicdefinition
test:historic:$year:
  stage: test
  image: registry.gitlab.com/islandoftex/images/texlive:TL$year-historic
  needs: ["build:historic:$year"]
  <<: *testdefinition
build:historic:$year-doc:
  stage: extrabuild
  needs: ["build:baseimage"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "yes"
    SRCFILES: "no"
  <<: *historicdefinition
build:historic:$year-src:
  stage: extrabuild
  needs: ["build:baseimage"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "no"
    SRCFILES: "yes"
  <<: *historicdefinition
build:historic:$year-doc-src:
  stage: extrabuild
  needs: ["build:baseimage"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "yes"
    SRCFILES: "yes"
  <<: *historicdefinition
EOF`"
		year=$(($year-1))
done
