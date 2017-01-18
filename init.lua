node.compile("tools.lua")
node.compile("ds18b20_small.lua")
node.compile("webserver.lua")

require("tools")
require('ds18b20_small');
dofile("webserver.lc")

gpio.mode(2,gpio.OUTPUT);
gpio.write(2,gpio.HIGH);
gpio.mode(3,gpio.OUTPUT);
gpio.write(3,gpio.HIGH);
gpio.mode(5,gpio.OUTPUT);
gpio.write(5,gpio.LOW);
gpio.mode(6,gpio.OUTPUT);
gpio.write(6,gpio.LOW);
gpio.mode(7,gpio.OUTPUT);
gpio.write(7,gpio.LOW);
-- chargement des variables 	
loadsetting();

wifi.setmode(wifi.SOFTAP)
cfg={}  ;
cfg.ssid=settings['SSID'];
wifi.ap.config(cfg);
delaitemp=tonumber(settings['delaitemp']);
delaimesure=tonumber(settings['delaimesure']);
tolerance=tonumber(settings['tolerance']);
marge_de_chauffe_grosse=tonumber(settings['marge_de_chauffe_grosse']);
marge_de_chauffe_petite=tonumber(settings['marge_de_chauffe_petite']);
settings['Etat']="OFF";
etapes={};
consigne=0;
i = 1;
for a,b,c in string.gmatch(settings['sequence'], "([0-9]+):([0-9]+):([0-9]+);?") do 
	etapes[i]={};
	etapes[i][1]=tonumber(a);
	etapes[i][2]=tonumber(b);
	etapes[i][3]=tonumber(c);
	print("Etape "..i.."/"..table.getn(etapes)..
	"   Duree "..etapes[i][1] .."mn"..
	"   Consigne "..etapes[i][2].."oC"..
	"   Cumul "..etapes[i][3].."s");
	i=i+1;
end

-- chargement des variables 
action="";
etape=1;
function stopsequence()
	tmr.stop(1);
	print("Stop");
	settings['Etat']="OFF";
end
function startsequence()
	settings['Etat']="ON";
	print("Start");
	tmr.alarm(1, delaimesure, 1, function()
			if ((temp + marge_de_chauffe_grosse ) < etapes[etape][2]) then
				action="CHAUFFE GROSSE";
				gpio.write(3,gpio.LOW); -- relai 3 Switch relai
				gpio.write(2,gpio.LOW); -- relai 2= alim 
				gpio.write(5,gpio.LOW);gpio.write(6,gpio.LOW);gpio.write(7,gpio.HIGH); -- led verte
			end
			if ((temp + marge_de_chauffe_petite )<etapes[etape][2]) then
				action="CHAUFFE PETITE";
				gpio.write(3,gpio.HIGH); -- relai 3 Switch relai
				gpio.write(2,gpio.LOW); -- relai 2= alim
				gpio.write(5,gpio.LOW);gpio.write(6,gpio.LOW);gpio.write(7,gpio.HIGH); -- led verte
			end
			if (temp>etapes[etape][2]) then
				action="STOP";
				gpio.write(2,gpio.HIGH); -- relai 2
				gpio.write(5,gpio.HIGH);gpio.write(6,gpio.LOW);gpio.write(7,gpio.LOW); -- led rouge
			end
			print("");
			print(
			"Etape "..etape.."/"..table.getn(etapes)..
			"   Duree "..etapes[etape][1] .."mn"..
			"   Consigne "..etapes[etape][2].."oC"..
			"   Cumul "..etapes[etape][3].."s"..
			"   Temperature "..temp.."oC => "..action);
			
			if (math.abs(etapes[etape][2] - temp)<=tolerance) then
				gpio.write(2,gpio.HIGH); -- relai 2
				gpio.write(5,gpio.LOW);gpio.write(6,gpio.HIGH);gpio.write(7,gpio.LOW);  -- led bleue
				etapes[etape][3]=etapes[etape][3]+(delaimesure/1000);
			else
				print ("pause");
			end
			if (etapes[etape][3]>= (60 * etapes[etape][1])) then
					if (etape == table.getn(etapes)) then
							tmr.stop(1);
							print("FIN");
							gpio.write(5,gpio.HIGH); gpio.write(6,gpio.HIGH); gpio.write(7,gpio.HIGH); 
							tmr.delay(1000); 
							gpio.write(5,gpio.LOW);gpio.write(7,gpio.LOW);gpio.write(7,gpio.LOW);
							tmr.delay(1000);
							gpio.write(5,gpio.HIGH); gpio.write(6,gpio.HIGH); gpio.write(7,gpio.HIGH); 
							tmr.delay(1000); 
							gpio.write(5,gpio.LOW);gpio.write(7,gpio.LOW);gpio.write(7,gpio.LOW);
					else
						etape=etape+1;
						print("---------------");
						print("ETAPE");
						gpio.write(5,gpio.HIGH); gpio.write(6,gpio.HIGH); gpio.write(7,gpio.HIGH); 
						tmr.delay(1000); 
						gpio.write(5,gpio.LOW);gpio.write(7,gpio.LOW);gpio.write(7,gpio.LOW);
					end
				end			
	end)
end
Kp=1;Ki=0;Kd=0;
somme_erreurs=0;variation_erreur=0;erreur=0;erreur_precedente=0;
tmr.alarm(0, delaitemp, 1, function()		
		--  D7 ds18b20 --------------------
	temp=getTemp(1) or 0
	settings['TEMP']=temp;
	if (settings['Etat']=="ON") then 
		print ("Temp eau  = "..temp.. " °C"..etapes[etape][2])
		consigne=etapes[etape][2];
		erreur = consigne - temp;
	    somme_erreurs = erreur+ somme_erreurs;
	    variation_erreur = erreur - erreur_precedente;
	    commande = Kp * erreur + Ki * somme_erreurs + Kd * variation_erreur;
	    print("commande :"..commande)
	    erreur_precedente = erreur
	end

end)
