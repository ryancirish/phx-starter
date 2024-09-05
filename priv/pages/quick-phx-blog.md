---
title: Quick Phx Blog 
author: rci
date: 2024-09-04
---

# MD of .mds

Suprised I'm back again so soon given the prior multi year hiatus. This time is another quick one, my experience with [Phoenix Pages](https://github.com/jsonmaur/phoenix-pages). Easyish way of getting setup, but theres some issues in the repo I should probably debug and pr. Also going to try out some other alterative libraries soon due to these limitations that I will explain below.

## Setup

The [docs are great](https://hexdocs.pm/phoenix_pages/readme.html) as usual with Elixir libraries. Check out [my last post](https://ryanc.irish/blog/roll-your-own-ssg-ash-phoenix) for more info about Ash, another great example of Elixir software. However, there are a couple of discrepancies I found to get up and running as of 09/2024. The first of them being that the dependencies require version 3.3 of `phoenix_html` while I had the latest. So if you need anything in version 4.0 feature wise, this will not cut it for you. Eventually, I might consider spending the time to work it out, submit a PR and also create an Igniter script for this. So your `mix.exs` should look something like this: (After run the traditional `mix deps.get` to get the package into your application library.)

```elixir
defp deps do
  [
    # ... other deps
    {:phoenix_html, "~> 3.3"},
    {:phoenix_pages, "~> 0.1"}
  ]
end
```

The [next issue](https://github.com/jsonmaur/phoenix-pages/issues/16) solved thanks to a friendly Github user has to do with the Earmark library. For one, you have to add it to your deps which is not in the docs `{:earmark_parser, "~> 1.4.20"}`. Secondly, you need to change the class structure in order to get things to compile appropriately. As [ThunderHeavyIndustries](https://github.com/ThunderHeavyIndustries) kindly pointed out adjusting the call in phoenix-pages/lib/phoenix_pages/markdown.ex on line 43 will fix your woes.

```elixir
case EarmarkParser.as_ast(contents, parser_opts) do

# to

case Earmark.Parser.as_ast(contents, parser_opts) do
```


## Structure

From there, business as usual via the docs. Structurally, you're creating a new route on the controller for the index, and for the actual pages that need to get rendered. The structure is agnostic to folder setup, for example I have my pages located under blog.

```elixir
  scope "/", RyancirishWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    get "/blog", PageController, :index
    pages "/blog/:page", PageController, :show,
      id: :blog,
      from: "priv/pages/**/*.md",
      attrs: [:title, :author, :date],
      sort: {:date, :desc}
  end
``` 

The attrs and sort are outlined in the docs but just make sure that the `:show` function is properly declared in the controller. The final gotcha is that the current docs are outdated for the index template rendering. I'm not the most familiar with the EEx template engine so I didn't notice it off the rip. The variables templated in must use the `assigns` class in order to render:

```elixir

<.link :for={page <- @pages} href={page.path}>
  <%= page.assigns.title %>
</.link>

```

In the process of discovering this I ended up expanding the loop to explicit declaration instead of inline but the functionality is the same.

```elixir
<%= for page <- @pages do %>
  <.link navigate={page.path}>
    <label class="white no-underline"><%= page.assigns.date %></label>
    <label class="lightest-blue hover-pink"><%= page.assigns.title %></label>
  </.link>
<% end %>
```

Overall, I think this is a great solution if your project meets parameters. Going forward there might be compatability issues but I hope I can either fix it or use my good 'ol manual route rendering I devised via Plug in the last post.

Thanks for stopping by!







