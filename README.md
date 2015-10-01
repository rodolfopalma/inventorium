# Inventorium
Inventorium was a project developed during an entrepreneurship course (ING2030) in the Engineering School at Pontificia Universidad Católica de Chile, which was intended to optimize business' stock management through predictive mathematical models.

## Tech Stack
Inventorium's backend is a Node server and a RethinkDB database. Also, we used `node-rio` which supplied a bridge for communication between Node and R, which was used to develop the mathematical models. All the Javascript files are compiled from Coffeescript.

## Requirements
- Node >= v0.12.4
- RethinkDB >= v2.0.2
- An instance running of Rserve

## Install
Clone the repo, then `npm install`, finally `grunt`.
