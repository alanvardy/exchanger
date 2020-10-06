# Exchanger

[![Build Status](https://github.com/alanvardy/exchanger/workflows/ex_check/badge.svg)](https://github.com/alanvardy/exchanger)

## Get set up

```
git clone git@github.com:alanvardy/exchanger.git
cd exchanger
docker-compose up -d # Stand up postgres and the mock API server
mix deps.get
mix check # Run the test suite
```
