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

if process.env.DATABASE_SSL
  Postgres.defaults.ssl = true

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

  client
    .query("SELECT storage FROM hubot LIMIT 1")
    .then((res) ->
      console.log('> [pg-brain]:', 'data found', res.rows[0]['storage']);
      robot.brain.mergeData JSON.parse(res.rows[0]['storage'].toString())
    )
    .catch((err) ->
      console.log('> pg-brain', err)
      robot.logger.error err
    )

  client.on "error", (err) ->
    console.log('> pg-brain', err);
    robot.logger.error err

  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET storage = $1", [JSON.stringify(data)])

  robot.brain.on 'close', ->
    client.end()
