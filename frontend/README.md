# relm

Rolling Implementation of Real World.  Currently implementing frontend in Elm.  Potentially backend in Elixir, but who knows.

https://github.com/gothinkster/realworld

## Development

Currently being developed in elm version 0.19.1

After installing elm, run the following command in the `frontend` directory.

```sh
elm-live src/Main.elm --pushstate --debug -- --output elm.js
```

Optionally, you can target a specific module if you have not yet integrated it
with `Main.elm`.

For example:

```sh
elm-live src/Page/Post.elm --pushstate --debug -- --output elm.js
```

## Building

To make a production-like static build:

```sh
elm make src/Main.elm --output elm.js
```

You can include the debugging capability in this build:

```sh
elm make src/Main.elm --output elm.js --debug
```

### Running the "static" build

```sh
yarn install && \
yarn run spa-server
```

This server will serve requests for any files it finds and will respond to all other requests with index.html.


