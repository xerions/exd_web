defmodule ExdWeb.PageController do
  use ExdWeb.Web, :controller

  plug :action

  @limit 15

  def index(conn, _params) do
    applications = remoter().applications(:exd_web) |> Map.keys
    render conn, "index.html", title: "Available application",
                               applications: format(applications)
  end

  def show(conn, %{"application" => application, "model" => model}) do
    fields = remoter().applications(:exd_web)[application][model][:fields]
    render conn, "model.html", title: application <> "/" <> model,
                               application: application, 
                               model: model, 
                               fields: format(fields)
  end

  def show(conn, %{"application" => application}) do
    models = remoter().applications(:exd_web)[application] |> Map.keys
    render conn, "application.html", title: application,
                                     application: application, 
                                     models: format(models)
  end

  def data(conn, %{"application" => application, "model" => model, "page" => page}) do
    page = page |> String.to_integer
    api = remoter().applications(:exd_web)[application][model]
    fields = api[:fields]
    [%{count: count}] = remoter.remote(api, "get", %{"count" => "id"})
    data = remoter.remote(api, "get", %{"limit" => @limit, "offset" => (page - 1) * @limit})
    render conn, "data.html", title: application <> "/" <> model,
                              page: page,
                              pages: trunc(Float.ceil(count / @limit)),
                              application: application, 
                              model: model, 
                              data: data,
                              fields: fields
  end

  def data(conn, %{"application" => application, "model" => model}) do
    redirect conn, to: "/" <> application <> "/" <> model <> "/view/1"
  end


  defp remoter() do
    Exd.Escript.Remoter.get(Application.get_env(:exd_web, :remoter, "dist")) 
  end

  defp format(applications), do: format(applications, 1)
  defp format([], _), do: []
  defp format([name | applications], n) do
    [{n, name}] ++ format(applications, n+1)
  end

  defp format_application({name, models}), do: {name, Map.size(models)}
end
