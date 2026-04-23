require 'socket'   # libreria TCP
require 'net/http' # Para hacer llamadas a internet
require 'json'     # Para leer la respuesta de la API

puerto = 5000
servidor = TCPServer.new(puerto)
puts "Servidor de Telnet iniciado en el puerto #{puerto}. Esperando conexiones..."

loop do
  # server.accept detiene el código aquí hasta que alguien (telnet) se conecte
  cliente = servidor.accept
  cliente.puts "Bienvenido al servidor Telnet de Nagasaki. Escribe un comando:"

  while linea = cliente.gets
    comando = linea.chomp.strip.downcase

    case comando
    when "time", "get time"
      hora_biscucuy = Time.now.getlocal("-04:00").strftime("%Y-%m-%dT%H:%M")
      cliente.puts hora_biscucuy

    when "weather"
      begin
        url = URI("https://api.open-meteo.com/v1/forecast?latitude=9.35&longitude=-69.98&current_weather=true")
        respuesta = Net::HTTP.get(url)
        datos = JSON.parse(respuesta)
        temperatura = datos["current_weather"]["temperature"]

        cliente.puts "El clima actual en Biscucuy es de #{temperatura} °C"
      rescue
        cliente.puts "Error al consultar el clima"
      end

    when "quit", "exit"
      cliente.puts "Adios!"
      break

    else
      cliente.puts "Comando no reconocido. Intenta con 'time', 'weather' o 'quit'."
    end
  end

  cliente.close
end
