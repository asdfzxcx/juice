defmodule Utils.System do
  require Logger

  def cmd(command, args, opts \\ []) do
    cd = Keyword.get(opts, :cd, nil)
    cd = if is_binary(cd), do: cd, else: File.cwd!()
    opts = Keyword.put(opts || [], :stderr_to_stdout, true)
    source? = Keyword.get(opts, :source, true)

    {run_command, run_args} =
      if source? do
        args =
          Enum.map(args, fn arg ->
            if String.contains?(arg, " ") do
              "\"#{arg}\""
            else
              arg
            end
          end)

        {"zsh", ["-ic", "#{command} #{Enum.join(args, " ")}"]}
      else
        {command, args}
      end

    Logger.debug("#{cd} $ #{command} #{Enum.join(args, " ")}")
    System.cmd(run_command, run_args, opts)
  end

  def in_dir(dir, fun) do
    cwd = File.cwd!()
    File.cd!(dir)

    try do
      fun.()
    rescue
      e -> raise e
    after
      File.cd!(cwd)
    end
  end

  def ding() do
    case cmd("ding", []) do
      {_, 0} -> :ok
      {output, _} -> {:error, output}
    end
  end
end
