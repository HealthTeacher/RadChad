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

  connectionString = process.env.DATABASE_URL

  if !connectionString?
    throw new Error('pg-brain requires a DATABASE_URL to be set.')

  client = new Postgres.Client({
    connectionString,
    ssl: {
      rejectUnauthorized: false
    }
  })
  client.connect()

  client.query("SELECT storage FROM hubot").then((res) ->
    robot.brain.mergeData JSON.parse(res.rows[0]['storage'].toString())
  ).catch (err) ->
    robot.logger.error "CLIENT QUERY ERROR: #{err}"

  client.on "error", (err) ->
    robot.logger.error "CLIENT ERROR: #{err}"

  robot.brain.on 'save', (data) ->
    query = client.query("UPDATE hubot SET storage = $1", [JSON.stringify(data)])

  robot.brain.on 'close', ->
    client.end()
