defmodule Eightysix.PjLink do
  defstruct [:ip, :password, :port, :socket, :secret]

  def connect(ip, password, port \\ 4352) do
    projector = %Eightysix.PjLink{ip: ip, password: password, port: port}
    _connect(projector)
  end

  def send_command(projector, command) do
    message = "#{projector.secret}%1#{command}\r"
    :gen_tcp.send(projector.socket, message)
    socket = projector.socket
    receive do
      {:tcp, ^socket, "%1" <> response} -> response
      {:tcp_closed, ^socket} -> send_command(_connect(projector), command)
    after
      1000 -> send_command(_connect(projector), command)
    end
  end

  def status?(projector) do
    "POWR=" <> status = send_command(projector, "POWR ?")
    status = String.trim(status)
    case status do
      "0" -> :off
      "1" -> :on
      "2" -> :cooling
      "3" -> :warmup
    end
  end

  def on(projector) do
    "POWR=" <> result = send_command(projector, "POWR 1")
    case String.trim(result) do
      "OK" -> {:ok, :on}
      "ERR" <> _ -> {:fail, status?(projector)}
    end
  end

  def off(projector) do
    "POWR=" <> result = send_command(projector, "POWR 0")
    case String.trim(result) do
      "OK" -> {:ok, :off}
      "ERR" <> _ -> {:fail, status?(projector)}
    end
  end

  defp _connect(projector) do
    {:ok, socket} = :gen_tcp.connect(projector.ip, projector.port, [:binary], 1000)
    projector = %{projector | socket: socket}
    case do_auth?(socket, projector.password) do
      {:noauth, _} -> projector
      {:auth, secret} -> %{projector | secret: secret}
    end
  end

  defp do_auth?(socket, password) do
    message = receive do
      {:tcp, ^socket, message} -> message
    end
    ["PJLINK", auth, rand] = String.split(message)
    case auth do
      "0" -> {:noauth, nil}
      "1" -> {:auth, auth_digest(rand, password)}
    end
  end

  defp auth_digest(rand, pass) do
    msg = :crypto.hash(:md5, "#{rand}#{pass}")
    Base.encode16(msg, case: :lower)
  end
end
