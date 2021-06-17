Vinci app initial version
provides a GraphQL backend written in nodejs (deployed on Heroku)
connecting to a cloud deployed MongoDB instance (https://cloud.mongodb.com)
authorizes Auth0 access tokens for queries and mutations to assure account owner is taking the action

mutations to populate database with Wikipedia article summaries included

Update deployed nodejs app on Heroku:
git add .
git commit -m ""
( heroku login )
git push heroku master

heroku logs --tail