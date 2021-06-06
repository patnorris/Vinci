const graphql = require('graphql');
const User = require('../models/user');
const Stream = require('../models/stream');
const Nugget = require('../models/nugget');
const request = require('request');
//const Mediawiki = require('nodemw');
const wiki = require('wikijs').default;

const { 
    GraphQLObjectType, GraphQLString, 
    GraphQLID, GraphQLInt,GraphQLSchema, 
    GraphQLList,GraphQLNonNull,
    GraphQLEnumType
} = graphql;

//Schema defines data on the Graph like object types(book type), relation between 
//these object types and describes how it can reach into the graph to interact with 
//the data to retrieve or mutate the data   

const UserType = new GraphQLObjectType({
    name: 'User',
    fields: () => ({
        id: { type: GraphQLID },
        loginId: { type: GraphQLString },
        username: { type: GraphQLString },
        createdAt: { type: GraphQLString },
        modifiedAt: { type: GraphQLString },
        stream: {
            type: StreamType,
            async resolve(parent, args){
                const streamEntry = (await Stream.find({ userId: parent.id }))[0];
                //streamEntry.user = await User.findById(streamEntry.userId);
                return streamEntry;
            }
        },
        savedNuggets: {
            type: new GraphQLList(NuggetType),
            async resolve(parent, args){ //TODO: paginate
                const user = await User.findById(parent.id);
                return user.savedNuggetIds.map(nuggetId => {
                    return Nugget.findById(nuggetId);
                });
            }
        },
        seenNuggets: {
            type: new GraphQLList(NuggetType),
            async resolve(parent, args){ //TODO: paginate
                const user = await User.findById(parent.id);
                return user.seenNuggetIds.map(nuggetId => {
                    return Nugget.findById(nuggetId);
                });
            }
        },
        likedNuggets: {
            type: new GraphQLList(NuggetType),
            async resolve(parent, args){ //TODO: paginate
                const user = await User.findById(parent.id);
                return user.likedNuggetIds.map(nuggetId => {
                    return Nugget.findById(nuggetId);
                });
            }
        },
        selectedTopics: {
            type: new GraphQLList(GraphQLString)
        },
        //TODO: add more
    })
});

async function assembleNewStream(currentStream) { //TODO: put job into queue and return (faster UX)
    const numberOfNewNuggets = 64;
    // include a few nuggets the user has saved or liked
    const user = await User.findById(currentStream.userId);
    const savedAndLikedNuggetIdsByUser = [];
    for (let index = 0; index < 2; index++) {
        if (user.likedNuggetIds.length > 0) {
            const randomIndexForLiked = Math.floor(Math.random() * (user.likedNuggetIds.length));
            savedAndLikedNuggetIdsByUser.push(user.likedNuggetIds[randomIndexForLiked]);
        }
        if (user.savedNuggetIds.length > 0) {
            const randomIndexForSaved = Math.floor(Math.random() * (user.savedNuggetIds.length));
            savedAndLikedNuggetIdsByUser.push(user.savedNuggetIds[randomIndexForSaved]); 
        }    
    }
    // and mainly new nuggets by topics selected by user
    let newNuggetIds = [];
    if (user.selectedTopics === null || user.selectedTopics.length === 0) {
        // no selected topics; only new random nuggets
        const randomNuggets = await Nugget.aggregate(
            [ { $sample: { size: numberOfNewNuggets - savedAndLikedNuggetIdsByUser.length } } ]
        );
        newNuggetIds = randomNuggets.map(nugget => { return nugget._id.toString(); });
    } else {
        // get nuggets for selected topics
        const numberOfNuggetsPerTopic = Math.floor((numberOfNewNuggets - savedAndLikedNuggetIdsByUser.length) / user.selectedTopics.length);
        for (let topicIndex = 0; topicIndex < user.selectedTopics.length; topicIndex++) {
            const topic = user.selectedTopics[topicIndex];
            let topicNuggets = [];
            if (topic === "Random") {
                // sample from all nuggets
                topicNuggets = await Nugget.aggregate(
                    [ { $sample: { size: numberOfNuggetsPerTopic } } ]
                );
            } else {
                // match nuggets by topic, sample from matched pool
                topicNuggets = await Nugget.aggregate(
                    [ 
                        { $match: { $expr: {$in: [topic, {$ifNull: ["$topics", [] ]} ]}}},
                        { $sample: { size: numberOfNuggetsPerTopic } } 
                    ]
                );
            }        
            newNuggetIds = newNuggetIds.concat(topicNuggets.map(nugget => { return nugget._id.toString(); }));
        }
    }
    // random shuffle new nuggets
    newNuggetIds = newNuggetIds.concat(savedAndLikedNuggetIdsByUser);
    shuffle(newNuggetIds);
    // keep the last ten nuggets of the current stream (unseen so far)
    const lastCurrentNuggetIds = currentStream.nuggetIds.slice(Math.max(currentStream.nuggetIds.length - 10, 0));
    // assemble all nuggets into one new stream (with the previously last nuggets as first)
    const newStream = lastCurrentNuggetIds.concat(newNuggetIds);
    await Stream.findOneAndUpdate(
        { _id: currentStream.id }, 
        { nuggetIds: newStream },
    );
    return true;
}

const StreamType = new GraphQLObjectType({
    name: 'Stream',
    fields: () => ({
        id: { type: GraphQLID },
        user: { type: UserType },
        createdAt: { type: GraphQLString },
        modifiedAt: { type: GraphQLString },
        nuggets: {
            type: new GraphQLList(NuggetType),
            async resolve(parent, args){
                const stream = await Stream.findById(parent.id);
                //assemble new stream if only twenty nuggets are left in current stream
                if (stream.currentPosition+20 >= stream.nuggetIds.length) {
                    await assembleNewStream(stream);  
                }
                await Stream.findOneAndUpdate(
                    { _id: parent.id }, 
                    { currentPosition: stream.currentPosition+20 >= stream.nuggetIds.length ? 0 : stream.currentPosition+10 },
                   /* function (error, success) {
                         if (error) {
                             console.log(error);
                         } else {
                             console.log(success);
                         } 
                     } */);
                return stream.nuggetIds.slice(stream.currentPosition, stream.currentPosition+10).map(nuggetId => {
                    return Nugget.findById(nuggetId);
                });
            }
        },
    })
});

const NuggetType = new GraphQLObjectType({
    name: 'Nugget',
    fields: () => ({
        id: { type: GraphQLID },
        createdBy: { 
            type: UserType,
            resolve(parent, args) {
                return User.findById(parent.creatorId);
            } 
        },
        nuggetType: { type: NuggetTypeEnum },
        content: { type: GraphQLString }, //TODO: probably change to NuggetContentType
        metaInfo: {
            type: GraphQLString, //TODO: change to NuggetInfoType
            resolve(parent, args) {
                return new Promise(async (resolve, reject) => {
                    const nugget = await Nugget.findById(parent.id);
                    //const result = [];
                    //result.push({ "source": nugget.source });
                    //return { source: nugget.source.toString(), resolveType: 'NuggetInfo' };
                    //return new NuggetInfoType(nugget.source);
                    //resolve(result);
                    //resolve({ "source": nugget.source });
                    resolve(nugget.source);
                });                
            } 
        },
        createdAt: { type: GraphQLString },
        modifiedAt: { type: GraphQLString },
        topics: {
            type: new GraphQLList(GraphQLString)
        },
        //TODO: add more
    })
});

const NuggetTypeEnum = new GraphQLEnumType({
    name: 'NuggetTypeEnum',
    values: {
        TEXT: {
            value: "TEXT",
        },
        IMAGE: {
            value: "IMAGE",
        },
        VIDEO: {
            value: "VIDEO",
        },
    },
});

const NuggetInfoType = new GraphQLObjectType({
    name: 'NuggetInfo',
    fields: () => ({
        source: { type: GraphQLString },
        //TODO: add more
    })
});

//RootQuery describe how users can use the graph and grab data.
const RootQuery = new GraphQLObjectType({
    name: 'RootQueryType',
    fields: {
        user: {
            type: UserType,
            args: { id: { type: GraphQLID } },
            async resolve(parent, args, context) {
                // secure query
                // only user themself can retrieve
                const requestedUser = await User.findById(args.id);;
                if (requestedUser.loginId === context.loggedInUser.nickname) {
                    return requestedUser
                }
                return null;
            }
        },
        userByLoginId: {
            type: UserType,
            args: { loginId: { type: GraphQLString } },
            resolve(parent, args, context) {
                console.log('in userByLoginId');
                console.log(args.loginId);
                console.log(context.loggedInUser.nickname);
                // secure query
                // only user themself can retrieve
                if (args.loginId === context.loggedInUser.nickname) {
                    console.log('in if');
                    // if no entry found, null will be returned (i.e. new user)
                    return User.findOne({ loginId: args.loginId });
                }
                console.log('after if');
                return null;
            }
        },
        nugget: {
            type: NuggetType,
            args: { id: { type: GraphQLID } },
            resolve(parent, args) {
                return Nugget.findById(args.id);
            }
        },
    }
});

async function assembleInitialStream(newUser, newUserStream) {
    const numberOfNewNuggets = 60;
    // include new nuggets by topics selected by user
    let newNuggetIds = [];
    if (newUser.selectedTopics === null || newUser.selectedTopics.length === 0) {
        // no selected topics; only new random nuggets
        const randomNuggets = await Nugget.aggregate(
            [ { $sample: { size: numberOfNewNuggets } } ]
        );
        newNuggetIds = randomNuggets.map(nugget => { return nugget._id.toString(); });
    } else {
        // get nuggets for selected topics
        const numberOfNuggetsPerTopic = Math.floor(numberOfNewNuggets / newUser.selectedTopics.length);
        for (let topicIndex = 0; topicIndex < newUser.selectedTopics.length; topicIndex++) {
            const topic = newUser.selectedTopics[topicIndex];
            let topicNuggets = [];
            if (topic === "Random") {
                // sample from all nuggets
                topicNuggets = await Nugget.aggregate(
                    [ { $sample: { size: numberOfNuggetsPerTopic } } ]
                );
            } else {
                // match nuggets by topic, sample from matched pool
                topicNuggets = await Nugget.aggregate(
                    [ 
                        { $match: { $expr: {$in: [topic, {$ifNull: ["$topics", [] ]} ]}}},
                        { $sample: { size: numberOfNuggetsPerTopic } } 
                    ]
                );
            }        
            newNuggetIds = newNuggetIds.concat(topicNuggets.map(nugget => { return nugget._id.toString(); }));
        }
    }
    // random shuffle new nuggets
    shuffle(newNuggetIds);
    // assemble all nuggets into one new stream (with the Vinci Welcome Nuggets as first)
    const newStream = ["6068ee5ea2fb59441c185003", "6068f120a2fb59441c185004"].concat(newNuggetIds);
    await Stream.findOneAndUpdate(
        { _id: newUserStream.id }, 
        { nuggetIds: newStream },
    );
    return true;
}
 
//Very similar to RootQuery helps user to add/update to the database.
const Mutation = new GraphQLObjectType({
    name: 'Mutation',
    fields: {
        addUser: {
            type: UserType,
            args: {
                loginId: { type: new GraphQLNonNull(GraphQLString) },
                username: { type: new GraphQLNonNull(GraphQLString) },
                topics: { type: new GraphQLList(GraphQLString) },
            },
            async resolve(parent, args) {
                console.log('#############################');
                console.log('in addUser');
                console.log(args.loginId);
                console.log(args.username);
                console.log(args.topics);

                try {
                    const user = new User({
                        username: args.username,
                        loginId: args.loginId,
                        savedNuggetIds: [],
                        seenNuggetIds: [],
                        likedNuggetIds: [],
                        selectedTopics: args.topics ? args.topics : [],
                    });
                    const createdUser = await user.save();
                    console.log('createdUser');
                    // create a stream for the user with some initial nuggets
                    const userStream = new Stream({
                        userId: createdUser.id,
                        nuggetIds: [],
                        currentPosition: 0,
                    });
                    const createdStream = await userStream.save();
                    console.log('createdStream');
                    await assembleInitialStream(createdUser, createdStream);
                    console.log('assembleInitialStream');
                    return createdUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        editUserProfile: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                username: { type: new GraphQLNonNull(GraphQLString) },
            },
            async resolve(parent, args, context) {
                // secure query
                // only user themself can mutate
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId, loginId: context.loggedInUser.nickname }, 
                        { username: args.username },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        editUserTopics: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                topics: { type: new GraphQLList(GraphQLString) },
            },
            async resolve(parent, args, context) {
                // secure query
                // only user themself can mutate
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId, loginId: context.loggedInUser.nickname }, 
                        { selectedTopics: args.topics },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        createNugget: {
            type: NuggetType,
            args: {
                creatorId: { type: new GraphQLNonNull(GraphQLID) },
                nuggetType: { type: new GraphQLNonNull(NuggetTypeEnum) },
                content: { type: new GraphQLNonNull(GraphQLString) },
                source: { type: new GraphQLNonNull(GraphQLString) },
                topic: { type: new GraphQLNonNull(GraphQLString) },
            },
            async resolve(parent, args) {
                try {
                    if(summary.length >= 10) { // prevent empty nuggets from being added
                        const creator = await User.findOne({ loginId: args.creatorId });
                        const nugget = new Nugget({
                            creatorId: creator.id,
                            nuggetType: args.nuggetType,
                            content: args.content,
                            source: args.source,
                            topics: [args.topic],
                        });
                        const createdNugget = await nugget.save();
                        await Stream.findOneAndUpdate(
                            { userId: creator.id }, 
                            { $push: { nuggetIds: createdNugget.id } },
                        /* function (error, success) {
                                if (error) {
                                    console.log(error);
                                } else {
                                    console.log(success);
                                } 
                            } */);
                        return createdNugget;
                    } else {
                        return "Not sure much can be learned from an empty nugget."
                    }               
                } catch (error) {
                    throw error;
                } 
            }
        },
        saveNuggetForUser: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                nuggetId: { type: new GraphQLNonNull(GraphQLID) },
            },
            async resolve(parent, args, context) {
                // secure query
                // only user themself can mutate
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId, loginId: context.loggedInUser.nickname }, 
                        { $addToSet: { savedNuggetIds: args.nuggetId } },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        removeSavedNugget: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                nuggetId: { type: new GraphQLNonNull(GraphQLID) },
            },
            async resolve(parent, args, context) {
                // secure query
                // only user themself can mutate
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId, loginId: context.loggedInUser.nickname }, 
                        { $pull: { savedNuggetIds: args.nuggetId } },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        markNuggetSeenForUser: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                nuggetId: { type: new GraphQLNonNull(GraphQLID) },
            },
            async resolve(parent, args) {
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId }, 
                        { $addToSet: { seenNuggetIds: args.nuggetId } },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        likeNuggetForUser: {
            type: UserType,
            args: {
                userId: { type: new GraphQLNonNull(GraphQLID) },
                nuggetId: { type: new GraphQLNonNull(GraphQLID) },
            },
            async resolve(parent, args) {
                try {
                    const updatedUser = await User.findOneAndUpdate(
                        { _id: args.userId }, 
                        { $addToSet: { seenNuggetIds: args.nuggetId, likedNuggetIds: args.nuggetId } },
                    );
                    return updatedUser;                 
                } catch (error) {
                    throw error;
                } 
            }
        },
        createRandomWikipediaNuggets: {
            type: GraphQLString,
            args: {
                creatorId: { type: GraphQLID },
            },
            async resolve(parent, args) {
                try {
                    for (let index = 0; index < 5; index++) {
                        const requestOpts = {
                            url: 'https://en.wikipedia.org/wiki/Special:Random',
                            followRedirects: false
                        };
                        request(requestOpts, async (error, response, body) => {
                            if (error) {
                                console.log('##########################error in request##########################');  
                                console.log(error);        
                                return "failed";
                            }
                            else {
                                const randomTopic = getLast(decodeURI(response.req.path)).split("_").join(" ");
                                try {
                                    const summary = await wiki().page(randomTopic).then(page => page.summary());
                                    if(summary.length >= 10) { // prevent empty nuggets from being added
                                        if(args.creatorId) {
                                            const nugget = new Nugget({
                                                creatorId: args.creatorId,
                                                nuggetType: "TEXT",
                                                content: summary,
                                                source: 'https://en.wikipedia.org'+response.req.path,
                                            });
                                            const createdNugget = await nugget.save();
                                            await Stream.findOneAndUpdate(
                                            { userId: args.creatorId }, 
                                            { $push: { nuggetIds: createdNugget.id } },
                                            /* function (error, success) {
                                                if (error) {
                                                    console.log(error);
                                                } else {
                                                    console.log(success);
                                                } 
                                            } */);
                                        } else {
                                            const nugget = new Nugget({
                                                creatorId: "60597211bb1ffb28389ee9e0",
                                                nuggetType: "TEXT",
                                                content: summary,
                                                source: 'https://en.wikipedia.org'+response.req.path,
                                            });
                                            const createdNugget = await nugget.save();
                                        }                              
                                        //return summary; 
                                    }                              
                                } catch (err) {
                                    console.log('##########################err in wiki()##########################');  
                                    console.log(err);        
                                    return "failed";
                                }
                            }
                        });
                    }
                    return "created";          
                } catch (error) {
                    throw error;
                } 
            }
        },
        createRandomWikipediaNuggetsByCategory: {
            type: GraphQLString,
            args: {
                creatorId: { type: GraphQLID },
                category: { type: GraphQLString },
            },
            async resolve(parent, args) {
                try {
                    const pagesInCategory = await wiki().pagesInCategory("Category:Nuclear_technology");
                    /* const page = await wiki().page(pagesInCategory[0]);
                    const summary = await page.summary();
                    console.log(summary);
                    const categories = await page.categories();
                    console.log(categories);
                    const topics = categories.map(category => category.replace("Category:", "").replace("_", " "));
                    console.log(topics);
                    const url = await page.url();
                    console.log(url);
                    return "test"; */
                    for (let index = 0; index < pagesInCategory.length; index++) {
                        //setTimeout(pauseForWikipedia, 30000);
                        await sleep(6000);
                        if (pagesInCategory[index].startsWith('Category')) {
                            // iterative function, call for category
                        }
                        else {
                            //const randomTopic = getLast(decodeURI(response.req.path)).split("_").join(" ");
                            try {
                                const page = await wiki().page(pagesInCategory[index]);
                                const summary = await page.summary();
                                const categories = await page.categories();
                                const topics = categories.map(category => category.replace("Category:", "").replace("_", " "));
                                const url = await page.url();
                                console.log(index);
                                if(summary.length >= 10) { // prevent empty nuggets from being added
                                    if(args.creatorId) {
                                        const nugget = new Nugget({
                                            creatorId: args.creatorId,
                                            nuggetType: "TEXT",
                                            content: summary,
                                            //source: 'https://en.wikipedia.org'+response.req.path,
                                            source: url,
                                            topics: topics,
                                        });
                                        const createdNugget = await nugget.save();
                                        await Stream.findOneAndUpdate(
                                        { userId: args.creatorId }, 
                                        { $push: { nuggetIds: createdNugget.id } },
                                    /* function (error, success) {
                                            if (error) {
                                                console.log(error);
                                            } else {
                                                console.log(success);
                                            } 
                                        } */);
                                    } else {
                                        const nugget = new Nugget({
                                            creatorId: "60597211bb1ffb28389ee9e0",
                                            nuggetType: "TEXT",
                                            content: summary,
                                            //source: 'https://en.wikipedia.org'+response.req.path,
                                            source: url,
                                            topics: topics,
                                        });
                                        const createdNugget = await nugget.save();
                                    }                              
                                    //return summary; 
                                }                              
                            } catch (err) {
                                console.log('##########################err in wiki()##########################');  
                                console.log(err);        
                                return "failed";
                            }
                        }
                    }
                    return "created";          
                } catch (error) {
                    console.log(error);
                    throw error;
                } 
            }
        },
    }
});

//Creating a new GraphQL Schema, with options query which defines query 
//we will allow users to use when they are making request.
module.exports = new GraphQLSchema({
    query: RootQuery,
    mutation: Mutation
});

function sleep(ms) {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    });
}   

async function parseResponse(error, response, body) {
    //console.log(body);
    if (error) {
        console.log(error);        
        done(error);
    }
    else {
      const randomTopic = getLast(decodeURI(response.req.path)).split("_").join(" ");
      console.log(randomTopic);
      /* var mwOpts = {
        server: 'en.wikipedia.org',
        path: '/w',
        debug: false
      };
      var wikipedia = new Mediawiki(mwOpts);
      const article = wikipedia.getArticle(randomTopic, (error, response, body) => {
        if (error) {
            console.log(error);        
          done(error);
        }
        else {
            //console.log('Mediawiki');
            //console.log(response);
        }
      }); */
      console.log('wiki page');
      //wiki().page(randomTopic).then(page => page.summary()).then(console.log);
      const summary = await wiki().page(randomTopic).then(page => page.summary());
      console.log(summary);
      return summary;
    }
  }
  function getLast(path) {
    var parts = path.split('/');
    if (parts.length > 0) {
      return parts[parts.length - 1];
    }
  }

function shuffle(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}