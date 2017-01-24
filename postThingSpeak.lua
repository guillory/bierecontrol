
function postThingSpeak()
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
       print("receive")
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("sent", function(connout, payloadout)
        print ("sent")
    end)
    connout:on("connection", function(connout, payloadout)
        print ("connection...")
        
        connout:send("GET /update?api_key="..API_KEY.."&field1=".. temp .. " HTTP/1.1\r\n"
		.. "Host: api.thingspeak.com\r\n"
		.. "Connection: close\r\n"
		.. "Accept: */*\r\n"
		.. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
		.. "\r\n")
         print ("send")
        
    end)
 
    connout:on("disconnection", function(connout, payloadout)
       print("disconnection")
         connout:close();
        collectgarbage();

        NodeSleep()
    end)
 
    connout:connect(80,'184.106.153.149') 
end

