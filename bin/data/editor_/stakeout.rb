require 'fssm'
require 'osc'
# Host = '192.168.1.100'
Host = 'localhost'
Port = 9001
c = OSC::UDPSocket.new

FSSM.monitor(Dir.pwd, '**/*.lua') do
  update {|base, relative|
    File.open(relative, "r"){|aFile|
      s = aFile.read
      m = OSC::Message.new('/eval', 'sf', s, 0.1)
      c.send m, 0, Host, Port
    }
  }
  delete {|base, relative|}
  create {|base, relative|}
end
