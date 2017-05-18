# hubot-bigly

Find out whether a bigly event has happened yet. You'll need a Google Civic Information API key, and lot's of patience.

See [`src/bigly.coffee`](src/bigly.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-bigly --save`

Then add **hubot-bigly** to your `external-scripts.json`:

```json
[
  "hubot-bigly"
]
```

Add the following ENV vars wherever you need to put them:

* `CIVIC_API_KEY` - Your Google Civic Information API key
* `BIGLY_ATTITUDE` - 'downbeat' (default) or 'upbeat'

## Sample Interaction

```
user1>> is Donald Trump still president?
hubot>> Yes... <emoji>
```

## NPM Module

https://www.npmjs.com/package/hubot-bigly
