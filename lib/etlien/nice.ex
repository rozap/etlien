defmodule Etlien.Nice do
  require Logger

  defp wait_then(func, timeout, tag) do
    Logger.warn("Waiting for #{timeout} to execute #{tag}")
    :timer.sleep(timeout)
    func.()
  end

  defp try_for(func, maximum, waited, _, _)
    when maximum != :infinity and waited > maximum do
    {:error, :timeout}
  end
  defp try_for(func, maximum, waited, wait, tag) do
    case wait_then(func, wait, tag) do
      {:error, :no_worker} ->
        try_for(func, maximum, waited + wait, wait * 2, tag)
      res ->
        res
    end
  end
  defp try_for(func, maximum, tag) do
    try_for(func, maximum, 0, 50, tag)
  end

  defp members_for!(group_name, true) do
    :pg2.get_local_members(group_name)
  end

  defp members_for!(group_name, false) do
    :pg2.get_members(group_name)
  end

  defp build_push_func(group_name, payload, local_only, work_func) do
    fn ->
      members_for!(group_name, local_only)
      |> Enum.shuffle
      |> Enum.reduce_while(:no_worker, fn worker, acc ->
        case work_func.(worker, payload) do
          :ok ->
            # This means a worker has accepted the payload
            {:halt, :found_worker}
          {:error, :max_capacity} ->
            # Try the next worker, maybe they will accept it
            Logger.warn("#{inspect worker} says it is at max_capacity")
            {:cont, acc}
          err ->
            IO.inspect err
            err
        end
      end)
    end
  end

  defp attempt(group_name, payload, timeout, local_only, work_func) do
    push_func = build_push_func(group_name, payload, local_only, work_func)
    case push_func.() do
      :found_worker -> :ok
      :no_worker -> try_for(push_func, timeout, "Push to #{group_name}")
      err -> err
    end
  end

  def cast_for(group_name, payload) do
    timeout = Application.get_env(:etlien, :nice)[:default_timeout]
    attempt(group_name, payload, timeout, false, &Workex.push_ack(&1, &2))
  end


  def cast_for(group_name, payload, timeout, local_only \\ false) do
    attempt(group_name, payload, timeout, local_only, &Workex.push_ack(&1, &2))
  end


end