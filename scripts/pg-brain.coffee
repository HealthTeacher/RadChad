# Description:
#   Stores the brain in Postgres
#
# Dependencies:
#   "pg": "~0.10.2"
#
# Configuration:
#   DATABASE_URL
#
# Commands:
#   None
#
# Notes:
#   Run the following SQL to setup the table and column for storage.
#
#   CREATE TABLE hubot (
#     id CHARACTER VARYING(1024) NOT NULL,
#     storage TEXT,
#     CONSTRAINT hubot_pkey PRIMARY KEY (id)
#   )
#   INSERT INTO hubot VALUES(1, NULL)
#
# Author:
#   danthompson

Postgres = require 'pg'

# sets up hooks to persist the brain into postgres.
module.exports = (robot) ->
  console.log('> [pg-brain]', 'init');

  database_url = process.env.DATABASE_URL

  if !database_url?
    console.log('> [pg-brain]', 'no database url!');
    throw new Error('pg-brain requires a DATABASE_URL to be set.')

  client = new Postgres.Client(database_url)
  client.connect()
  console.log "pg-brain connected to #{database_url}."

  query = client.query("SELECT storage FROM hubot LIMIT 1")
  query.on 'row', (row) ->
    console.log('> [pg-brain]:', 'query complete');
    if row['storage']?
      console.log('> [pg-brain]:', 'data found');
      robot.brain.mergeData JSON.parse(row['storage'].toString())
      console.log "pg-brain loaded."

  client.on "error", (err) ->
    console.log('> pg-brain', err);
    robot.logger.error err

  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET storage = $1", [JSON.stringify(data)])
    console.log "pg-brain saved."

  robot.brain.on 'close', ->
    client.end()
