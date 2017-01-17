local httpRequest={}
httpRequest["/"]="index.html";
httpRequest["/index.html"]="index.html";


local getContentType={};
getContentType["/"]="text/html";
getContentType["/index.html"]="text/html";
local filePos=0;
local nbline=0;

if srv then srv:close() srv=nil end
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        print("[New Request]");
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
         _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local formDATA = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=([^&]+)&*") do
          --     print("["..k.."="..v.."]");
                formDATA[k] = v
            end   
        end
       
        if formDATA['startsequence'] then startsequence(); end 
        if formDATA['stopsequence'] then stopsequence(); end 
        if formDATA['update'] then
          print("mettre a jour settings");
            for k,v in pairs(settings) do 
                if ( formDATA[k] ==nil ) then
                else
                   settings[k]=decodeURI(formDATA[k]);
                end
            end
            savesetting();
        end

        if getContentType[path] then
            requestFile=httpRequest[path];
            print("[Sending file "..requestFile.."]");            
            nbline=0;
            line='';  file.open(requestFile, "r") line=file.readline()   lines={} while  (line) do  table.insert(lines, line)  line=file.readline()  end file.close()
            conn:send("HTTP/1.1 200 OK\r\nContent-Type: "..getContentType[path].."\r\n\r\n");            
        else
            print("[File "..path.." not found]");
            conn:send("HTTP/1.1 404 Not Found\r\n\r\n")
            conn:close();
            collectgarbage();
        end
    end)
    conn:on("sent",function(conn)
        if requestFile then
                nbline=nbline+1
                line=lines[nbline];
                for k,v in pairs(settings) do 
                     line=string.gsub(line, "{{"..k.."}}", v)
                end
                conn:send(line);
                if nbline<table.getn(lines) then return; end
           
        end
        print("[Connection closed]");
        conn:close();
        collectgarbage();
    end)
end)