#!/bin/bash

# for some reason GitLab CI doesn't accept the `test` jobs to have
# needs: ["build:historic:$year"]…

year=$((`date +%Y`-1))
while [ $year -gt 2013 ]
do
		echo "`cat <<EOF
build:iso:$year:
  variables:
    CURRENTRELEASE: $year
  <<: *isodefinition
build:historic:$year:
  needs: ["build:iso:$year"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "no"
    SRCFILES: "no"
  <<: *historicdefinition
test:historic:$year:
  image: \\$RELEASE_IMAGE:TL$year-historic
  <<: *testdefinition
  only:
    variables:
      - \\$HISTORICALRELEASES == "true"
build:historic:$year-doc:
  needs: ["build:iso:$year"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "yes"
    SRCFILES: "no"
  <<: *historicdefinition
build:historic:$year-src:
  needs: ["build:iso:$year"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "no"
    SRCFILES: "yes"
  <<: *historicdefinition
build:historic:$year-doc-src:
  needs: ["build:iso:$year"]
  variables:
    CURRENTRELEASE: $year
    DOCFILES: "yes"
    SRCFILES: "yes"
  <<: *historicdefinition
EOF`"
		year=$(($year-1))
done
