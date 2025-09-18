defmodule Azure do
  def account_show() do
    {result, 0} = Utils.System.cmd("az", ["account", "show"])
    JSON.decode!(result)
  end

  def account_list() do
    {result, 0} = Utils.System.cmd("az", ["account", "list"])
    JSON.decode!(result)
  end

  def select_sub(opts \\ []) do
    all_accounts = account_list()

    id =
      if opts[:id] do
        acc = Enum.find(all_accounts, fn %{"id" => acc_id} -> acc_id =~ opts[:id] end)
        acc["id"]
      end

    name =
      if opts[:name] do
        acc = Enum.find(all_accounts, fn %{"name" => acc_name} -> acc_name =~ opts[:name] end)
        acc["name"]
      end

    id_or_name = id || name || raise "must be existing id or name"

    # az account set --subscription <ID_или_Имя_подписки>
    {_result, 0} = System.cmd("az", ["account", "set", "--subscription", id_or_name])
    print_account_list()
    :ok
  end

  def print_account_list() do
    selected_account = account_show()

    account_list()
    |> Enum.map(fn acc ->
      active? = if selected_account["id"] == acc["id"], do: "Yes", else: ""
      Map.put(acc, "active", active?)
    end)
    |> Scribe.print(data: ["id", "name", "active"])
  end
end
