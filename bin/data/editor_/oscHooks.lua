-- this file is for controlling the app over osc. yay!

Receiver = class(function(o)
  o.r = bludOscReceiver();
  o.r:setup(9001);
  o.mess = bludOscMessage();
end)

function Receiver:update()
  while (self.r:hasWaitingMessages()) do
    self.r:getNextMessage(self.mess)
    -- all of the responders to the various functions
    if self.mess:getAddress() == "/restart_game" then
      mainState = ScrapeLevel();
    end
    if self.mess:getAddress() == "/eval" then
      -- lol eval!
      assert(loadstring(self.mess:getArgAsString(0)))();
    end
  end
end
