#--------------------------------------- Initiation ---------------------------------------#

pcl_file = "MotorTaskMainPractice.pcl";
scenario = "MotorTaskPractice";

active_buttons = 6;
button_codes = 1,2,3,4,5,6;

default_background_color = 0, 0, 0;
default_font = "arial";
default_font_size = 24;
default_text_color = 235, 235, 235;
default_formatted_text = true;

response_matching = simple_matching; 
no_logfile = true;					# because custom logfile is generated

begin;


#------------------------------------ Text Stimuli ---------------------------------------#

array {

picture { text { caption = "Dadelijk in de scanner gaat u een taak doen die ongeveer 10 minuten duurt. Deze taak gaat u nu al buiten de scanner kort oefenen. 
Leest u hiervoor deze instructies. U kunt verder- of teruggaan door op de rechter- of linker pijltoets te drukken. Als er iets niet duidelijk is, kunt u de onderzoeker om uitleg vragen. 
Als u aan het einde van de instructies bent aangekomen, laat het dat aan de onderzoeker weten zodat deze nog aanvullende uitleg kan geven."; max_text_width = 1100; text_align = align_left; } t_Instructions1a; x = 0; y = 200;
			 text { caption = " <i> Gebruik de pijltoetsen om verder of terug te gaan </i> "; } t_Instructions1b; x = 0; y = -350; 
			 } p_Instructions1;

picture { text { caption = "De taak die u zo meteen gaat doen, duurt ongeveer 10 minuten. Nu doorloopt u een verkorte versie ervan. 
U krijgt zo 4 cirkels te zien. Deze staan voor de toetsen 1 t/m 4 op het toetsenbord. \n \n \n \n \n \n
Een aantal van de 4 cirkels is dicht (oftewel grijs gevuld). 
Dit aantal kan variëren tussen 1 en 3, zie de voorbeelden hieronder."; max_text_width = 1100; text_align = align_left; } t_Instructions2a; x = 0; y = 200; 
			 bitmap {filename = "keyboard.jpg"; preload = true; scale_factor = 0.8;} b_Keyb; x = 0; y = 170;
			 bitmap {filename = "stim1.jpg"; preload = true; scale_factor = 0.27;} b_Exta; x = -400; y = -150;
			 bitmap {filename = "stim7.jpg"; preload = true; scale_factor = 0.27;} b_Int2c; x = 0; y = -150;
			 bitmap {filename = "stim12.jpg"; preload = true; scale_factor = 0.27;} b_Int3b; x = 400; y = -150;
			 text t_Instructions1b; x = 0; y = -350; 
			 } p_Instructions2;

picture { text { caption = "De dichte cirkels geven de toetsen aan, die als correct antwoord worden geteld indien u deze indrukt. 
Indien maar één cirkel dicht is, drukt u op de toets die met deze grijs gevulde cirkel overeenkomt. 
Zie hieronder de mogelijke plaatjes en het bijbehorende antwoord."; max_text_width = 1100; text_align = align_left; } t_Instructions3a; x = 0; y = 200; 
			 bitmap b_Exta; x = -450; y = -100;
			 bitmap {filename = "stim2.jpg"; preload = true; scale_factor = 0.27;} b_Extb; x = -150; y = -100;
			 bitmap {filename = "stim3.jpg"; preload = true; scale_factor = 0.27;} b_Extc; x = 150; y = -100;
			 bitmap {filename = "stim4.jpg"; preload = true; scale_factor = 0.27;} b_Extd; x = 450; y = -100;
			 bitmap {filename = "keys.jpg"; preload = true; scale_factor = 1.2;} b_keys; x = 0; y = -200;
			 #text {	caption = "Linker toets \n (1)"; } t_Instructions3b; x = -450; y = -200;
			 #text {	caption = "2e toets van links \n (2)"; } t_Instructions3c; x = -150; y = -200;
			 #text {	caption = "3e toets van links \n (3)"; } t_Instructions3d; x = 150; y = -200;
			 #text {	caption = "Rechter toets \n (4)"; } t_Instructions3e; x = 450; y = -200;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions3;

picture { text { caption = "Indien er meer dan één dichte cirkel is, zijn er meerdere correcte antwoorden mogelijk. U kunt dan kiezen welke van de toetsen, die als correct antwoord tellen, u gaat indrukken. Soms zijn er meerdere correcte antwoorden mogelijk, bijvoorbeeld 2 of 3. 
Onafhankelijk van hoeveel opties beschikbaar zijn, hoeft u altijd maar een enkele toets in te drukken. Er volgen nu enkele voorbeelden."; max_text_width = 1100; text_align = align_left; } t_Instructions4a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions4;

picture { text { caption = "In het linker voorbeeld hieronder heeft u de keuze uit twee correcte antwoorden. Als u dit plaatje ziet kunt u de linker toets of de derde toets van links indrukken. Drukt u op een andere toets, dan wordt u reactie als fout geteld. 
In sommige gevallen moet u kiezen uit drie correcte antwoorden. Bijvoorbeeld als u het rechter plaatje ziet. In dit geval kunt u kiezen of u op de meest linker toets of op een van de twee rechter toetsen drukt. Let op, u hoeft altijd maar op één enkele toets te drukken." ; max_text_width = 1100; text_align = align_left; } t_Instructions5a; x = 0; y = 200; 
			 bitmap {filename = "stim6.jpg"; preload = true; scale_factor = 0.27;} b_Int2b; x = -150; y = -100;
			 bitmap {filename = "stim13.jpg"; preload = true; scale_factor = 0.27;} b_Int2d; x = 150; y = -100;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions5;

picture { text { caption = "Soms zijn de cirkels die u ziet rood omlijnd zoals in de voorbeelden hieronder. Reageer dan NIET en druk op GEEN enkele toets. "; max_text_width = 1100; text_align = align_left; } t_Instructions7a; x = 0; y = 200; 
			 bitmap {filename = "stim17.jpg"; preload = true; scale_factor = 0.27;} b_Catch1b; x = -300; y = -100;
			 bitmap {filename = "stim22.jpg"; preload = true; scale_factor = 0.27;} b_Catch2c; x = 0; y = -100;
			 bitmap {filename = "stim27.jpg"; preload = true; scale_factor = 0.27;} b_Catch3d; x = 300; y = -100;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions6;

picture { text { caption = "Het gaat bij deze taak om snelheid, maar ook nauwkeurigheid. Probeer dus zo snel mogelijk te reageren, maar daarbij ook weinig fouten te maken. 
Probeer ook, indien u de keuze uit meerdere toetsen heeft, niet altijd dezelfde toets te gebruiken, maar wissel af zodat u alle vier vingers gebruikt. 
Verder is het belangrijk dat u pas op het moment waarop u het plaatje ziet een keuze maakt en dus zo spontaan mogelijk gaat bepalen welke toets u gaat indrukken."; max_text_width = 1100; text_align = align_left; } t_Instructions8a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions7;

picture { text { caption = "Tussen de plaatjes in, is een korte wachtperiode van enkele seconden. U ziet dan een klein kruisje op het scherm. Probeer tijdens deze korte wachtperiode naar het scherm te blijven kijken en niet afgeleid te raken."; max_text_width = 1100; text_align = align_left; } t_Instructions9a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions8;

picture { text { caption = "Dit is het einde van de instructies. Neem nu nog even contact op met de onderzoeker en geef aan of u de taak goed begrijpt, of dat extra uitleg nodig is. 
De onderzoeker zal nu de toetsen die u voor de taak gaat gebruiken aanwijzen. De taak begint pas als u één van de antwoordtoetsen indrukt."; max_text_width = 1100; text_align = align_left; } t_Instructions10a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions9;

picture { text { caption = "Dit is het einde van de oefentaak. Er volgt nu nog een korte uitleg over wat u in de scanner te wachten staat. 
Lees ook deze uitleg even goed door en gebruik weer de pijltoetsen om verder- of terug te gaan. "; max_text_width = 1100; text_align = align_left; } t_Instructions11a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions10;

picture { text { caption = "In de scanner zult u een klein kastje met 4 knoppen in u hand vasthouden. Dit kastje ziet er zo uit. \n \n \n \n \n \n
Met deze 4 knoppen kunt u tijdens de taak reageren zoals u het net ook al heeft gedaan. Net als bij de oefentaak kunt u dadelijk in de scanner zelf de taak starten. 
Dat betekent dat u opnieuw een scherm te zien krijgt met korte instructies. Op het moment dat u één van de 4 knoppen indrukt start de taak met enige vertraging."; max_text_width = 1100; text_align = align_left; } t_Instructions12a; x = 0; y = 150; 
			 bitmap {filename = "buttonbox_right.jpg"; preload = true; scale_factor = 0.5;} b_buttonbox; x = 0; y = 220;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions11;

picture { text { caption = "U ziet dan op het scherm de tekst \"Wachten op scanner ... \" en terwijl dit scherm te zien is, hoort u ineens nieuwe geluiden, die door de scanner worden veroorzaakt. 
Houd er dus rekening ermee dat op dat moment het geluid iets luider kan worden, zodat u niet schrikt. Na enkele seconden wordt u nog kort erop gewezen dat de taak dus daadwerkelijk begint."; max_text_width = 1100; text_align = align_left; } t_Instructions13a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions12;

picture { text { caption = "Omdat de taak in de scanner iets langer duurt, wordt de taak twee keer onderbroken voor een korte pauze van ongeveer 20 seconden. Om uw aandacht toch even vast te houden, krijgt u dan een klein kruisje op het scherm te zien. 
Het begin van een pauze wordt kort aangekondigd door de tekst \"Kijk naar het kruisje\". Kijk dan gedurende de 20 seconden naar het kruisje. Probeer niet te staren, maar knipper af en toe om te voorkomen dat uw ogen uitdrogen. \n
Het einde van de pauze en begin van de taak wordt aangekondigd door de tekst \"Let op, de taak begint\"."; max_text_width = 1100; text_align = align_left; } t_Instructions14a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions13;

picture { text { caption = "Naast de taak, worden in de scanner ook nog een paar overige scans gemaakt waarbij u niets hoeft te doen en alleen maar rustig moet blijven liggen. 
Elke scan zal net iets andere geluiden veroorzaken, dus wees niet ongerust als ineens nieuwe onverwachte geluiden te horen zijn. Verder kan bij sommige scans het bed waarop u ligt een beetje schudden. Let op, communicatie met de onderzoeker is alleen mogelijk tussen de scans in. 
U kunt dan op vragen en opmerkingen van de onderzoeker reageren."; max_text_width = 1100; text_align = align_left; } t_Instructions15a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions14;

picture { text { caption = "Als er problemen zijn tijdens het scannen, waardoor u contact met de onderzoeken op moet nemen, kunt u alarm slaan door in een alarmknopje te knijpen. 
Gebruik dit knijpballetje alleen maar in noodsituaties, bijvoorbeeld als u benauwd voelt, veel pijn in uw rug heeft, of vanwege een andere reden moet stoppen. Op dergelijke noodgevallen na, wordt de scansessie normaal niet onderbroken. 
Dat betekent u ligt in totaal een uur in de scanner en u kunt niet tussendoor opstaan om bijvoorbeeld naar de wc te gaan. Probeer dan ook het hele uur zo stil mogelijk te blijven liggen."; max_text_width = 1100; text_align = align_left; } t_Instructions16a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions15;

picture { text { caption = "Dit is het einde van de instructies. Heeft u nog vragen? Stel deze dan vooral aan de onderzoeker."; max_text_width = 1100; text_align = align_left; } t_Instructions17a; x = 0; y = 150; 
			 text { caption = " <i> Druk op de rechter pijltoets om af te sluiten </i> "; } t_Instructions15b; x = 0; y = -350;
			 } p_Instructions16;

} a_Instructions;

picture { text{ caption = " "; } t_InBetweenBlocks; x=0; y=0; } p_InBetweenBlocks;		# to signal break of 20s


#------------------------------------ Picture Stimuli --------------------------------------#

picture { } p_Default;		# black screen

picture { box { height = 1; width = 40; color = 255,255,255; } b_Horz; x = 0; y = 0;
			 box { height = 40; width = 1; color = 255,255,255; } b_Vert; x = 0; y = 0; } p_Fixation;		# Fixation Cross

picture { bitmap {filename = " "; preload = false; scale_factor = 0.5;} b_Cue; x = 0; y = 0; } p_Cue;

#------------------------------------ Stimuli Events/ trial objects --------------------------------------#
# In between trials, e.g. instructions & during baseline/ rest phase
trial{ 
		trial_duration = forever; trial_type = first_response;
		stimulus_event{
			picture p_Instructions1;
			time=0; code = 5; response_active = true; target_button = 5,6; } event_instructions;
		} trial_instructions;				# instruction before start experiment

trial{ 
		trial_duration = 4000; trial_type = fixed;
		picture p_InBetweenBlocks;
		time=0; code = 6; response_active = false;
		} trial_inbetweenblocks;			# display text marking the beginning of either rest baseline or new block

trial{ 
		trial_duration = 20000; trial_type = fixed;
		picture p_Fixation;
		time=0; code = 7; response_active = false;
		} trial_baseline;						# display fixation cross during the baseline "block" lasting 20s

# For presentation of stimuli which are part of the trials
trial{ 
		trial_duration = 2000; trial_type = fixed;							# duration will be set for each trial, random(2000, 4000) --> 2-4s
		picture p_Fixation;
		time=0; code = 8; response_active = false;
		} trial_fixation;						# display fixation at the beginning of each new trial

trial{ 
		trial_duration = 2000; trial_type = first_response;				# show cue until button press, but max 2s
		stimulus_event{
			picture p_Cue;
			time = 0; code = 9; response_active = true; target_button = 1; duration = response; } event_cue;			# Target buttons are set later dependent on cue
		} trial_cue;							# display the cue signaling button press

