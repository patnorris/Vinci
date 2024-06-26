const express = require('express');
const graphqlHTTP = require('express-graphql');
const { ApolloServer } = require('apollo-server-express');

const graphqlSchema = require('./schema/schema');
const app = express();

const mongoose = require('mongoose');
const axios = require('axios');
if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

//This route will be used as an endpoint to interact with Graphql, 
//All queries will go through this route. 
/* app.use('/graphql', graphqlHTTP({
    //Directing express-graphql to use this schema to map out the graph 
    schema: graphqlSchema,
    //Directing express-graphql to use graphiql when goto '/graphql' address in the browser
    //which provides an interface to make GraphQl queries
    //graphiql: true
})); */

const AUTH0_DOMAIN = 'dev-elgwq523.us.auth0.com';
let loggedInUsers = {}; // TODO: probably a better option is needed to accomplish this

const context = async req => {
  try {
    if (!loggedInUsers[req.headers.authorization]) {
      const url = `https://${AUTH0_DOMAIN}/userinfo`;
      const response = await axios.get(url, { headers: { Authorization: `${req.headers.authorization}` } });
      // console.log('in context response.data');
      // console.log(response.data);
      // console.log(response.data.toString());
      if (response.data.sub.toString().includes('google')) {
        // console.log('in context if google');
        // console.log(response.data.nickname.toString());
        response.data.name = response.data.nickname.toString().concat('@gmail.com');
      }
      // console.log(response.data);
      loggedInUsers[req.headers.authorization] = response.data;
    }
    // console.log('in context loggedInUsers[req.headers.authorization]');
    // console.log(loggedInUsers[req.headers.authorization]);  
    return { loggedInUser: loggedInUsers[req.headers.authorization] };
  } catch (error) {
    console.log('error in context');
    console.log(error);
  }
  return { };
};

const server = new ApolloServer({
  //context: { driver, neo4jDatabase: process.env.NEO4J_DATABASE },
  schema: graphqlSchema,
  introspection: true,
  playground: true,
  context: ({ req }) => context(req),
});

const uri = `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@cluster0.nged9.mongodb.net/${process.env.MONGO_DB}?retryWrites=true&w=majority`;
const options = { useNewUrlParser: true, useUnifiedTopology: true };

const port = process.env.PORT || process.env.GRAPHQL_SERVER_PORT || 4001;
const path = process.env.GRAPHQL_SERVER_PATH || '/graphql';
const host = process.env.GRAPHQL_SERVER_HOST || '0.0.0.0';

server.applyMiddleware({ app, path });

mongoose
  .connect(uri, options)
  .then(() => app.listen({ host, port, path }, () => {
    console.log(`GraphQL server ready at http://${host}:${port}${path}`)
  }))
  .catch(error => {
    throw error
  });