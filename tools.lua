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
	if (settings['mcg']==nil 	 or tonumber(settings['mcg'])==nil)	
		then settings['mcg']=1000; 	end
	if (settings['mcp']==nil 	or tonumber(settings['mcp'])==nil)	
		then settings['mcp']=1000; 	end
	if (settings['Kp']==nil 	or tonumber(settings['Kp'])==nil)	
	then settings['Kp']=1; 	end
	if (settings['Ki']==nil 	or tonumber(settings['Ki'])==nil)	
	then settings['Ki']=1; 	end
	if (settings['Kd']==nil 	or tonumber(settings['Kd'])==nil)	
	then settings['Kd']=1000; 	end
	settingstemp=settings['sequence'];
	settings['sequence']="";
	for a,b,c in string.gmatch(settingstemp, "([0-9]+):([0-9]+):([0-9]+);?") do 
		print (a,":",b,":",c,";");
		settings['sequence']=settings['sequence']..a..":"..b..":"..c..";";
	end
	if ( settings['sequence']=="") then settings['sequence']="0:0:0"; end 	
	print("Seq "..settings['sequence']);

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