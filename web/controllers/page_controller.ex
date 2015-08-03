defmodule ExdWeb.PageController do
  use ExdWeb.Web, :controller

  plug :action

  @limit 15

  def index(conn, _params) do
    applications = remoter().applications(:exd_web) |> Map.keys
    render conn, "index.html", applications: format(applications)
  end

  def show(conn, %{"application" => application, "model" => model}) do
    fields = remoter().applications(:exd_web)[application][model][:fields]
    render conn, "model.html", application: application, 
                               model: model, 
                               fields: format(fields)
  end

  def show(conn, %{"application" => application}) do
    models = remoter().applications(:exd_web)[application] |> Map.keys
    render conn, "application.html", application: application, 
                                     models: format(models)
  end

  def delete(conn, %{"application" => application, "model" => model, "id" => id, "page" => page}) do
    id = id |> String.to_integer
    api = remoter().applications(:exd_web)[application][model]
    remoter.remote(api, "delete", %{"id" => id})
    [%{count: count}] = remoter.remote(api, "get", %{"count" => "id"})
    last_page = Float.ceil(count / @limit) |> trunc
    page = case String.to_integer(page) do 
      p when p > last_page and last_page > 0 -> last_page 
      0 -> 1
      p -> p
    end
    redirect conn, to: "/" <> application <> "/" <> model <> "/view/" <> Integer.to_string(page)
  end
  def delete(conn, params), do: delete(conn, Map.put(params, "page", "1"))

  def edit(conn, %{"application" => application, "model" => model, "id" => id}) do
    id = id |> String.to_integer
    api = remoter().applications(:exd_web)[application][model]
    fields = api[:fields]
    data = remoter.remote(api, "get", %{"id" => id})
    render conn, "edit.html", id: id,
                              application: application, 
                              model: model, 
                              data: data,
                              fields: fields
  end

  def new(conn, %{"application" => application, "model" => model}) do
    api = remoter().applications(:exd_web)[application][model]
    fields = api[:fields]
    render conn, "edit.html", id: "new",
                              application: application, 
                              model: model, 
                              data: %{},
                              fields: fields
  end

  def create(conn, %{"application" => application, "model" => model, "data" => data}) do
    api = remoter().applications(:exd_web)[application][model]
    remoter.remote(api, "post", data)
    redirect conn, to: "/" <> application <> "/" <> model <> "/view"
  end

  def update(conn, %{"application" => application, "model" => model, "id" => id, "data" => data}) do
    api = remoter().applications(:exd_web)[application][model]
    remoter.remote(api, "put", Map.put(data, "id", String.to_integer(id)))
    redirect conn, to: "/" <> application <> "/" <> model <> "/view"
  end

  def data(conn, %{"application" => application, "model" => model, "page" => page}) do
    page = page |> String.to_integer
    api = remoter().applications(:exd_web)[application][model]
    fields = api[:fields]
    [%{count: count}] = remoter.remote(api, "get", %{"count" => "id"})
    data = remoter.remote(api, "get", %{"limit" => @limit, "offset" => (page - 1) * @limit})
    render conn, "data.html", page: page,
                              pages: trunc(Float.ceil(count / @limit)),
                              application: application, 
                              model: model, 
                              data: data,
                              pattern: nil,
                              fields: fields
  end

  def data(conn, %{"application" => application, "model" => model}) do
    redirect conn, to: "/" <> application <> "/" <> model <> "/view/1"
  end

  def search(conn, %{"application" => application, "model" => model, "pattern" => pattern}) do
    api = remoter().applications(:exd_web)[application][model]
    fields = api[:fields]
    data = remoter.remote(api, "get", %{"where" => "name like \"%" <> pattern <> "%\""})
    render conn, "data.html", page: 0,
                              pages: 0,
                              application: application, 
                              model: model, 
                              data: data,
                              pattern: pattern,
                              fields: fields
  end

  defp remoter() do
    Exd.Escript.Remoter.get(Application.get_env(:exd_web, :remoter, "dist")) 
  end

  defp format(applications), do: format(applications, 1)
  defp format([], _), do: []
  defp format([name | applications], n) do
    [{n, name}] ++ format(applications, n+1)
  end
end
