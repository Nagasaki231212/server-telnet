require 'socket' # libreria TCP

puerto = 5000
servidor = TCPServer.new(puerto)
puts "Servidor de Telnet iniciado en el puerto #{puerto}. Esperando las conexion..."

loop do
  # server.accept detiene el código aquí hasta que alguien (telnet) se conecte
  cliente = servidor.accept
  cliente.puts "Bienvenido al servidor Telnet de Nagasaki, Escribe un comando:"

  while linea = cliente.gets
    comando = linea.chomp.strip.downcase

    case comando
    when "time", "get time"
      hora_biscucuy = Time.now.getlocal("-04:00").strftime("%Y-%m-%dT%H:%M")
      cliente.puts hora_biscucuy

    when "quit", "exit"
      cliente.puts "Adios!"
      break

    else
      cliente.puts "Comando no reconocido. Intenta con 'time' o 'quit'."
    end
  end

  cliente.close
end
