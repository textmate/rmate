#!/usr/bin/env ruby
# encoding: UTF-8

$VERBOSE = true                         # -w
$KCODE   = "U" if RUBY_VERSION < "1.9"  # -KU

require 'optparse'
require 'socket'
require 'fileutils'

VERSION_STRING = 'rmate version 1.3 (2011-10-18)'

class Settings
  attr_accessor :host, :port, :wait, :force, :verbose

  def initialize
    @host, @port = 'localhost', 52698

    @host = ENV['RMATE_HOST'].to_s if ENV.has_key? 'RMATE_HOST'
    @port = ENV['RMATE_PORT'].to_i if ENV.has_key? 'RMATE_PORT'

    if @host == 'auto' and (conn = ENV['SSH_CONNECTION'])
      @host = conn.split(' ').first
    end

    @wait    = false
    @force   = false
    @verbose = false

    read_disk_settings
    parse_cli_options
  end

  def read_disk_settings
    # TODO
  end

  def parse_cli_options
    OptionParser.new do |o|
      o.on(           '--host=name',       "Connect to host.", "Use 'auto' to detect the host from SSH.", "Defaults to #{@host}.") { |v| @host    = v          }
      o.on('-p',      '--port=#', Integer, "Port number to use for connection.", "Defaults to #{@port}.")                       { |v| @port    = v          }
      o.on('-w',      '--[no-]wait',       'Wait for file to be closed by TextMate.')                                        { |v| @wait    = v          }
      o.on('-f',      '--force',           'Open even if the file is not writable.')                                         { |v| @force   = v          }
      o.on('-v',      '--verbose',         'Verbose logging messages.')                                                      { |v| @verbose = v          }
      o.on_tail('-h', '--help',            'Show this message.')                                                             { puts o; exit              }
      o.on_tail(      '--version',         'Show version.')                                                                  { puts VERSION_STRING; exit }
      o.parse!
    end
  end
end

class Command
   def initialize(name)
     @command   = name
     @variables = {}
     @data      = nil
     @size      = nil
   end

   def []=(name, value)
     @variables[name] = value
   end

   def read_file(path)
     @size = File.size(path)
     @data = File.open(path, "rb") { |io| io.read(@size) }
   end

   def send(socket)
     socket.puts @command
     @variables.each_pair do |name, value|
       value = 'yes' if value === true
       socket.puts "#{name}: #{value}"
     end
     if @data
       socket.puts "data: #{@size}"
       socket.puts @data
     end
     socket.puts
   end
end

def handle_save(socket, variables, data)
  path = variables["token"]
  $stderr.puts "Saving #{path}" if $settings.verbose
  begin
    FileUtils.cp(path, "#{path}~") if File.exist? path
    File.open(path, 'wb') { |file| file << data }
    File.unlink("#{path}~")        if File.exist? "#{path}~"
  rescue
    # TODO We probably want some way to notify the server app that the save failed
    $stderr.puts "Save failed! #{$!}" if $settings.verbose
  end
end

def handle_close(socket, variables, data)
  path = variables["token"]
  $stderr.puts "Closed #{path}" if $settings.verbose
end

def handle_cmd(socket)
  cmd = socket.readline.chomp

  variables = {}
  data = ""

  while line = socket.readline.chomp
    break if line.empty?
    name, value     = line.split(': ', 2)
    variables[name] = value
    data << socket.read(value.to_i) if name == "data"
  end
  variables.delete("data")

  case cmd
  when "save"   then handle_save(socket, variables, data)
  when "close"  then handle_close(socket, variables, data)
  else          abort "Received unknown command “#{cmd}”, exiting."
  end
end

def connect_and_handle_cmds(host, port, cmds)
  socket = TCPSocket.new(host, port)
  server_info = socket.readline.chomp
  $stderr.puts "Connect: ‘#{server_info}’" if $settings.verbose

  cmds.each { |cmd| cmd.send(socket) }

  socket.puts "."
  handle_cmd(socket) while !socket.eof?
  socket.close
  $stderr.puts "Done" if $settings.verbose
end

## MAIN

$settings = Settings.new

## Parse arguments.
cmds = []
ARGV.each do |path|
  abort "File #{path} is not writable! Use -f/--force to open anyway." unless $settings.force or File.writable? path or not File.exists? path
  $stderr.puts "File #{path} is not writable. Opening anyway." if not File.writable? path and File.exists? path and $settings.verbose
  cmd                 = Command.new("open")
  cmd['display-name'] = "#{Socket.gethostname}:#{path}"
  cmd['real-path']    = File.expand_path(path)
  cmd['data-on-save'] = true
  cmd['re-activate']  = true
  cmd['token']        = path
  cmd.read_file(path)               if File.exist? path
  cmd['data']         = "0"     unless File.exist? path
  cmds << cmd
end

unless $settings.wait
  pid = fork do
    connect_and_handle_cmds($settings.host, $settings.port, cmds)
  end
  Process.detach(pid)
else
  connect_and_handle_cmds($settings.host, $settings.port, cmds)
end
