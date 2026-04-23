# frozen_string_literal: true

require 'socket'   # libreria TCP
require 'net/http' # Para hacer llamadas a internet
require 'json'     # Para leer la respuesta de la API


def manejar_archivo(comando, cliente)
  nombre_archivo = comando.sub('get ', '').strip

  if File.exist?(nombre_archivo)
    cliente.puts "Inicio de #{nombre_archivo}"
    cliente.puts File.read(nombre_archivo)
    cliente.puts 'Un Exito'
  else
    cliente.puts "Error 404: El archivo '#{nombre_archivo}' no se encontro en el servidor."
  end
end

def dar_la_hora(cliente)
  cliente.puts Time.now.getlocal('-04:00').strftime('%Y-%m-%dT%H:%M')
end

def dar_el_clima(cliente)
  url = URI('https://api.open-meteo.com/v1/forecast?latitude=9.35&longitude=-69.98&current_weather=true')
  respuesta = Net::HTTP.get(url)
  temperatura = JSON.parse(respuesta)['current_weather']['temperature']
  cliente.puts "El clima actual en Biscucuy es de #{temperatura} °C"
rescue StandardError
  cliente.puts 'Error al consultar el clima'
end

def procesar_desconocido(comando, cliente)
  if comando.start_with?('get ')
    manejar_archivo(comando, cliente)
  else
    cliente.puts "Comando no encontrado. Intenta con 'time', 'weather', 'get [archivo]' o 'quit'."
  end
end

def procesar_comando(comando, cliente)
  case comando
  when 'time', 'get time' then dar_la_hora(cliente)
  when 'weather'          then dar_el_clima(cliente)
  when 'quit', 'exit'
    cliente.puts 'Adios!'
    return true
  else
    procesar_desconocido(comando, cliente)
  end
  false
end

puerto = 1212
servidor = TCPServer.new(puerto)
puts "Servidor de Telnet iniciado en el puerto #{puerto}. Esperando La Conexion..."

loop do
  cliente = servidor.accept
  cliente.puts 'Bienvenido al servidor Telnet de Nagasaki, Escribe un comando:'

  while (linea = cliente.gets)
    comando = linea.chomp.strip.downcase
    break if procesar_comando(comando, cliente)
  end

  cliente.close
end
