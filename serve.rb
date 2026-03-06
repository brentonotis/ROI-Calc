require 'socket'

port = (ENV['PORT'] || 8080).to_i
dir = File.dirname(__FILE__)

server = TCPServer.new('0.0.0.0', port)
$stderr.puts "Serving on http://localhost:#{port}"

loop do
  client = server.accept
  request = client.gets
  next unless request

  path = request.split(' ')[1]
  path = '/index.html' if path == '/'

  file_path = File.join(dir, path)
  if File.exist?(file_path) && !File.directory?(file_path)
    content = File.read(file_path)
    ext = File.extname(file_path)
    ct = case ext
         when '.html' then 'text/html'
         when '.js' then 'application/javascript'
         when '.css' then 'text/css'
         when '.json' then 'application/json'
         when '.png' then 'image/png'
         when '.jpg','.jpeg' then 'image/jpeg'
         else 'application/octet-stream'
         end
    client.print "HTTP/1.1 200 OK\r\nContent-Type: #{ct}; charset=utf-8\r\nContent-Length: #{content.bytesize}\r\nConnection: close\r\n\r\n"
    client.print content
  else
    body = "Not Found"
    client.print "HTTP/1.1 404 Not Found\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}"
  end
  client.close
rescue => e
  $stderr.puts e.message
end
