function encodeURI(str)
	if (str) then
		str = string.gsub (str, "\n", "\r\n")
		str = string.gsub (str, "([^%w ])",	function (c) return string.format ("%%%02X", string.byte(c)) end)
   end
   return str
end
	
function decodeURI(s)
	if(s) then
		s = string.gsub(s, '%%0D%%0A', ';')
		s = string.gsub(s, '%%(%x%x)', 	function (hex) return string.char(tonumber(hex,16)) end )
		s = string.gsub (s, "+", " ")
	end

	return s
end

function savesetting()
	print ("Update");
	if settings['SSID']==nil 		then settings['SSID']="BIERE"; 		end
	if (settings['delaitemp']==nil 	 or tonumber(settings['delaitemp'])==nil)	
		then settings['delaitemp']=1000; 	end
	if (settings['delaimesure']==nil or tonumber(settings['delaimesure'])==nil)	
		then settings['delaimesure']=1000; 	end
	if (settings['tolerance']==nil 	 or tonumber(settings['tolerance'])==nil)	
		then settings['tolerance']=1000; 	end
	if (settings['marge_de_chauffe_grosse']==nil 	 or tonumber(settings['marge_de_chauffe_grosse'])==nil)	
		then settings['marge_de_chauffe_grosse']=1000; 	end
	if (settings['marge_de_chauffe_petite']==nil 	or tonumber(settings['marge_de_chauffe_petite'])==nil)	
		then settings['marge_de_chauffe_petite']=1000; 	end
	settings=settings['sequence'];
	settings['sequence']="";
	for a,b,c in string.gmatch(settings['sequence'], "([0-9]+):([0-9]+):([0-9]+);?") do 
			settings['sequence']+=a,":",b,":",c,";";
	end
   	file.remove("settings.cfg" )
	file.open("settings.cfg" , "w" )
	for k,v in pairs(settings) do 
    	--string=string..k.."='"..v.."',"
    	k = string.gsub (k, " ", "");
    	print (k.."="..decodeURI(v));
    	file.writeline(k.."="..decodeURI(v))
    end
	file.close()
end
function loadsetting()
	print ("Load")
    settings={};
	if 	file.open("settings.cfg" , "r" ) then 
		line=file.readline()   
		 while  (line) do  
	 	   for k, v in string.gmatch(line, "([^=]+)=(.*)")  do  
	 	   	v = string.gsub(v, "\n", "")   
	 	   	settings[k]=v;
	 	   	print (k,"=>",v)
	 	   end
		 	line=file.readline()  ;
		 end 
		file.close()
	else
		print("fichier settings.cfg introuvable");
	end
	
	return settings;
end 


function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

