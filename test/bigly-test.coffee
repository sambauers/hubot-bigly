Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/bigly.coffee')

describe 'bigly', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()
