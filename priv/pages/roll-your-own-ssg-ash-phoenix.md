---
title: Roll Your Own SSG with Ash and Phoenix
author: rci
date: 2024-09-03
---

todo: add links
# Exploring Elixir, Phoenix, and Ash Framework

I don't need to wax poetic about the refreshing nature of Elixir, there are multiple posts, lectures, and learning resources available. Phoenix framework is a breath of sanity in the landscape- multitudes of derivations of simply serving an .html file.

I have used the technology to republish my personal site, and there is no shortage of first rate cloud providers that provide the tooling needed to easily deploy. Due to this, I can see the framework and language gaining a ton of traction over the next few years. I intend to crest that wave, and exploring exciting apps in the ecosystem like Ash is a great way to do that.

## Ash Framework

Ash Framework is maturing, recently hitting its 3.1 release this July. I say maturity because the brilliant creator of Ash, Zach Daniel, has mentioned that there are no plans for a version 4. Thus, any subsequent updates are going to be way smaller and scope and not change in "general shape" going forward. This is music coming to my ears as other language and framework ecosystems can feel frantic and break backwards compatibility. Not going to name names *cough* react *cough* (I might be one of the biggest React haters out there). Perhaps in the future I will elaborate on that comparison.

For now, let's see why Ash is so great- eliminating boilerplate. For more info you can nerd out here, but essentially you are given a composable set of building blocks that are designed to be extended. In a world where every `create-language-app` comes shipped with a ton of assumptions this is like a sharp scalpel. Begone tutorial creator that literally shows you how to follow the docs, instead the docs themselves provide great tutorials on the extension capabilities and the documentation of those extensions is also excellent. Side note- online LLMs are very out of date on Ash. Essentially, if you model the Domain in Ash's paradigm, your application will come with the first class support of the extensibility. Doing more with less sounds good to me! 

This sounds relatively too good to be true…lets examine an absolute barebones api I created as a template for Ash: 

## The Process

(prerequisite- Postgres running)

There were a multitude of attempts made to get this going. Essentially we'll start with a base phx project to work from, except rather than deploy just another live view app, we want to strip this baby to the raw frame:  

```bash
mix phx.new alpina \
--no-assets \
--no-dashboard \
--no-gettext \
--no-html \
--no-live \
--no-mailer \
--verbose
```

These phx.new flags are important they can be found here {add link} but essentially they make an absolutely raw project. 
From there you need to follow the tutorial to add a Domain/Resource that connects to a local Postgres instance then can query a create route. Igniter provides a handy generator from the phx docs but it contains a bit more boilerplate than I would have liked so I did it myself.

I'm actually going to reproduce exactly what I did but just know it was much more painstaking and by no means optimized, however in the process I learned a ton.

```bash
mix archive.install hex igniter_new
```

Add to mix.exs:
```elixir
{:ash, "~> 3.0"},
{:picosat_elixir, "~> 0.2"}
```

Add to .formatter.exs:
```elixir
import_deps: [:ecto, :ecto_sql, :phoenix, :ash],
```

```bash
mix deps.get
mix igniter.install ash_postgres
mix igniter.install ash_json_api
mix setup
mix compile
mix phx.server
```

If you navigate to http://localhost:4000/api/json/swaggerui you can see that the api is running and ready for routes

Let's add a few routes:

to router.ex:
```elixir
pipeline :browser do
  plug :accepts, ["html"]
  plug :fetch_session
  plug :fetch_flash
  plug :protect_from_forgery
  plug :put_secure_browser_headers
end

scope "/", BlogTestWeb do
  pipe_through :browser

  get "/", PageController, :index
end
```

Create a new pagecontroller under the controllers section of the _web section of your app:

```elixir
defmodule BlogTestWeb.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, File.read!(Application.app_dir(:blog_test, "priv/static/index.html")))
  end
end
```

Add an html file to priv/static and run phx.mix again to see the changes!

I made the mistake of just being able to query a resource + ping it via api but when it came to deploying to prod it was another battle. When I started on fly, ran into problems getting a proper response, and on gigalixir it wouldn't deploy at all. Since I had never used fly until then, I decided to refocus back to gigalixir. Let's examine what else is needed.

Create a .tool-versions file with the associated entries. We will need them for asdf later.
```
erlang 27.0
elixir 1.17.2
nodejs 22.7.0
```

Add assets.deploy script to mix digest:
```elixir
defp aliases do
  [
    setup: ["deps.get", "ecto.setup"],
    "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
    "ecto.reset": ["ecto.drop", "ecto.setup"],
    test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
    "assets.deploy": [
      "esbuild alpina --minify",
      "phx.digest"
    ]
  ]
end
```

Also add deps:
```elixir
{:esbuild, "~> 0.8", runtime: Mix.env() == :dev}
```

Add esbuild config to config.exs:
```elixir
config :esbuild,
  version: "0.17.11",
  blog_test: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
]
```

Create an assets folder at root with a package.json:
```json
{
  "scripts": {
    "deploy": "cd .. && mix assets.deploy && rm -f _build/esbuild"
  }
}
```

Create a js folder in this folder with an app.js:
```javascript
console.log("App initialized");
```

Add to prod.exs:
```elixir
config :blog_test, BlogTestWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"
```

```bash
mix deps.get
mix esbuild blog_test
```

Should be built. Moment of truth…deploy to gigalixir!
```bash
git init
git add -A
git commit -m 'f1rst'
gigalixir create
gigalixir create:db
git push gigalixir main
```

And you're done!

A small caveat though, there is no database_url configured so you're going to get 502'd. Should probably run ecto commands to create this when testing out your Domain/Resources.


You can save this content as a .md file, for example `roll-your-own-ssg-with-ash-and-phoenix.md`. The metadata at the top of the file (between the `---` lines) is called YAML front matter and is commonly used in static site generators to provide metadata about the content.

```