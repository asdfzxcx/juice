defmodule Utils.Chrono do
  def now() do
    Timex.to_datetime(Timex.now(), Timex.Timezone.local())
  end

  def to_string(str, opts \\ [])

  def to_string(str, opts) when is_binary(str) do
    case from_string(str, opts) do
      nil -> str
      dt -> Utils.Chrono.to_string(dt)
    end
  end

  def to_string(dt, _opts) do
    # "2024-01-02 @ 12:34:56 -06:00"
    Timex.format!(dt, "%Y-%m-%d @ %H:%M:%S %:z", :strftime)
  end

  def from_string(str, opts \\ []) do
    case Timex.parse(str, "{ISO:Extended}") do
      {:ok, dt} ->
        tz = Keyword.get(opts, :timezone, nil)

        case tz do
          :local -> Timex.to_datetime(dt, local_timezone())
          nil -> dt
          tz -> Timex.to_datetime(dt, tz)
        end

      {:error, _} ->
        nil
    end
  end

  def local_timezone() do
    Timex.Timezone.local()
  end
end
