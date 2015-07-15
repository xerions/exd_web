defmodule ExdWeb.PageController do
  use ExdWeb.Web, :controller

  plug :action

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
