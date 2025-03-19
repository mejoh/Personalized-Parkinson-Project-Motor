####### INITIATION #######

pcl_file = "RewardTaskMain_prac.pcl";
scenario = "RewardTask_prac";

active_buttons = 4;
button_codes = 1,2,3,4;

default_background_color = 0, 0, 0;
default_font = "arial";
default_font_size = 24;
default_text_color = 235, 235, 235; 
default_text_align = align_left;

response_matching = simple_matching; 
no_logfile = true;					# because custom logfile is generated

begin;


#--------------------------- Text stimuli for beginning and end of experiment ------------------------------#
array {
			
picture { text { caption = "In de scanner zult u een tweede taak uitvoeren, die ook 10 minuten zal duren. U gaat nu een korte versie van deze taak uitvoeren. Hier kunt u de instructies lezen. Net als eerder, gebruikt u hier weer de pijltoetsen om verder- of terug te gaan. Vraag het gerust aan de onderzoekers als er iets onduidelijk is, en laat het ze weten als u aan het eind van deze instructies bent gekomen."; max_text_width = 1100; text_align = align_left; } t_Instructions1a; x = 0; y = 200;
			 text { caption = " Gebruik de pijltoetsen om verder of terug te gaan "; } t_Instructions1b; x = 0; y = -350; 
			 } p_Instructions1;

picture { text { caption = "Twee symbolen verschijnen links en rechts van het kruis in het midden van het scherm. Kies één van de twee symbolen door een klik op het toetsenbord. Het rechter symbool kiest u door 2 in te toetsen, voor het linker symbool toetst u 1. U moet altijd één symbool selecteren!"; max_text_width = 1100; text_align = align_left; } t_Instructions2a; x = 0; y = 200; 
			 bitmap {filename = "keyboard2left.jpg"; preload = true; scale_factor = 1;} b_Keyb; x = 0; y = -175;
			 bitmap {filename = "Stim11A.bmp"; preload = true; scale_factor = 0.8;} b_sym1; x = -150; y = 50;
			 bitmap {filename = "fix_cross.jpg"; preload = true; scale_factor = 0.25;} b_fix; x = 0; y = 50;
			 bitmap {filename = "Stim11B.bmp"; preload = true; scale_factor = 0.8;} b_sym2; x = 150; y = 50;
			 text t_Instructions1b; x = 0; y = -350; 
			 } p_Instructions2;

picture { text { caption = "Er verschijnt een pijl onder het symbool dat u gekozen heeft."; max_text_width = 1100; text_align = align_left; } t_Instructions3a; x = 0; y = 200; 
			 bitmap {filename = "Stim11A.bmp"; preload = true; scale_factor = 0.8;} b_sym3; x = -150; y = 75;
			 bitmap {filename = "fix_cross.jpg"; preload = true; scale_factor = 0.25;} b_fix1; x = 0; y = 75;
			 bitmap {filename = "Stim11B.bmp"; preload = true; scale_factor = 0.8;} b_sym4; x = 150; y = 75;
			 arrow_graphic { coordinates = 0, -5 , 0, 5; line_width = 5; head_width = 50; head_type = head_flat; head_length = 30; } arrowGraph; x = -150; y = 25;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions3;
			
picture { text { caption = "Nadat u een symbool gekozen heeft, kunt u... \n \n \n \n \n \n  - Niks krijgen. \n \n \n \n \n \n  - Tien euro winnen. \n \n \n \n \n \n  - Tien euro verliezen."; max_text_width = 1100; text_align = align_left; } t_Instructions4a; x = 0; y = 200;
			 bitmap {filename = "neutral_.bmp"; preload = true; scale_factor = 0.7;} b_neut; x = 250; y = 330;
			 bitmap {filename = "win_.bmp"; preload = true; scale_factor = 0.7;} b_win; x = 250; y = 120;
			 bitmap {filename = "loss_.bmp"; preload = true; scale_factor = 0.7;} b_loss; x = 250; y = -100; 
			 text t_Instructions1b; x = 0; y = -400;
			 } p_Instructions4;
			
picture { text { caption = "Om de kans te hebben om te winnen, moet u een keuze maken en één van de twee knoppen indrukken. Als u niets doet of te langzaam reageert, zult u het volgende zien..." ; max_text_width = 1100; text_align = align_left; } t_Instructions5a; x = 0; y = 200; 
			 text { caption = "######"; font_size = 48; } NoSlowResponse; x = 0; y = 0;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions5;
			
picture { text { caption = "De twee symbolen die op hetzelfde scherm worden weergegeven, zijn niet gelijk in termen van uitkomst: bij de ene heb je meer kans om niets te krijgen dan bij de ander. Elk symbool heeft zijn eigen betekenis, ongeacht waar (links of rechts van het centrale kruis) of wanneer deze wordt weergegeven."; max_text_width = 1100; text_align = align_left; } t_Instructions6a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions6;
			
picture { text { caption = "Het doel van het spel is om zo veel mogelijk geld te winnen."; max_text_width = 1100; text_align = align_left; } t_Instructions7a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions7;
			
picture { text { caption = "Tijdens deze taak kunt u echt geld verdienen. Hoeveel geld u verdient is afhankelijk van hoe u presteert tijdens de taak. U zult 10% ontvangen van het gemiddelde bedrag dat u wint."; max_text_width = 1100; text_align = align_left; } t_Instructions8a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions8; 
			
picture { text { caption = "Veel succes"; max_text_width = 1100; text_align = align_left; } t_Instructions9a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions9;
			
picture { text { caption = "Dit is het einde van de instructies. Neem nu nog even contact op met de onderzoeker en geef aan of u de taak goed begrijpt, of dat extra uitleg nodig is. De onderzoeker zal nu de toetsen die u voor de taak gaat gebruiken aanwijzen. De taak begint pas als u één van de antwoordtoetsen indrukt."; max_text_width = 1100; text_align = align_left; } t_Instructions10a; x = 0; y = 200; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions10;
			
picture { text { caption = "Dit is het einde van de oefentaak. Er volgt nu nog een korte uitleg over wat u in de scanner te wachten staat. Deze informatie is gelijk aan die van de vorige taak, behalve in het volgende stukje over de knoppenkast.
Lees ook deze uitleg even goed door en gebruik weer de pijltoetsen om verder- of terug te gaan. "; max_text_width = 1100; text_align = align_left; } t_Instructions11a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions11;
			
picture { text { caption = "In de scanner zult u een klein kastje met 4 knoppen in u hand vasthouden. Dit kastje ziet er zo uit. \n \n \n \n \n \n
Met deze 2 knoppen kunt u tijdens de taak reageren zoals u het net ook al heeft gedaan. Net als bij de oefentaak kunt u dadelijk in de scanner zelf de taak starten. 
Dat betekent dat u opnieuw een scherm te zien krijgt met korte instructies. Op het moment dat u één van de 4 knoppen indrukt start de taak met enige vertraging."; max_text_width = 1100; text_align = align_left; } t_Instructions12a; x = 0; y = 150; 
			 bitmap {filename = "buttonbox_left.jpg"; preload = true; scale_factor = 0.5;} b_buttonbox; x = 0; y = 220;
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions12;
			
picture { text { caption = "U ziet dan op het scherm de tekst \"Wachten op scanner ... \" en terwijl dit scherm te zien is, hoort u ineens nieuwe geluiden, die door de scanner worden veroorzaakt. 
Houd er dus rekening ermee dat op dat moment het geluid iets luider kan worden, zodat u niet schrikt. Na enkele seconden wordt u nog kort erop gewezen dat de taak dus daadwerkelijk begint."; max_text_width = 1100; text_align = align_left; } t_Instructions13a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions13;
			
picture { text { caption = "Naast de taak, worden in de scanner ook nog een paar overige scans gemaakt waarbij u niets hoeft te doen en alleen maar rustig moet blijven liggen. 
Elke scan zal net iets andere geluiden veroorzaken, dus wees niet ongerust als ineens nieuwe onverwachte geluiden te horen zijn. Verder kan bij sommige scans het bed waarop u ligt een beetje schudden. Let op, communicatie met de onderzoeker is alleen mogelijk tussen de scans in. 
U kunt dan op vragen en opmerkingen van de onderzoeker reageren."; max_text_width = 1100; text_align = align_left; } t_Instructions14a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions14;
			
picture { text { caption = "Als er problemen zijn tijdens het scannen, waardoor u contact met de onderzoeken op moet nemen, kunt u alarm slaan door in een alarmknopje te knijpen. 
Gebruik dit knijpballetje alleen maar in noodsituaties, bijvoorbeeld als u benauwd voelt, veel pijn in uw rug heeft, of vanwege een andere reden moet stoppen. Op dergelijke noodgevallen na, wordt de scansessie normaal niet onderbroken. 
Dat betekent u ligt in totaal een uur in de scanner en u kunt niet tussendoor opstaan om bijvoorbeeld naar de wc te gaan. Probeer dan ook het hele uur zo stil mogelijk te blijven liggen."; max_text_width = 1100; text_align = align_left; } t_Instructions15a; x = 0; y = 150; 
			 text t_Instructions1b; x = 0; y = -350;
			 } p_Instructions15;
			
picture { text { caption = "Dit is het einde van de instructies. Heeft u nog vragen? Stel deze dan vooral aan de onderzoeker."; max_text_width = 1100; text_align = align_left; } t_Instructions16a; x = 0; y = 150; 
			 text { caption = " Druk op de rechter pijltoets om af te sluiten"; } t_Instructions15b; x = 0; y = -350;
			 } p_Instructions16;

} a_Instructions;

picture { text{ caption = " "; } t_InBetweenBlocks; x=0; y=0; } p_InBetweenBlocks;		# to signal break of 20s


#------------------------------------ Task Cues & task-related stimuli --------------------------------------#
###################picture { } p_Default;			# black screen

picture { box { height = 1; width = 35; color = 255,255,255; } b_Horz; x = 0; y = 0;			# fixation cross
			 box { height = 35; width = 1; color = 255,255,255; } b_Vert; x = 0; y = 0; } p_Fixation;

# display a bitmap pair and the fixation cross, bitmaps are set for each trial
picture { bitmap {filename = " "; preload = false; scale_factor = 1;} b_Stimulus1; x = -125; y = 0; 
			 bitmap {filename = " "; preload = false; scale_factor = 1;} b_Stimulus2; x = 125; y = 0;
			 box { height = 1; width = 35; color = 255,255,255; } b_Hor; x = 0; y = 0;
			 box { height = 35; width = 1; color = 255,255,255; } b_Ver; x = 0; y = 0;} p_Stimuli; 

# arrays with bitmap pairs, one for the gain condition and one for the loss condition
# filename is set based on subject number, symbols associated with positive/ negative outcome are counterbalanced
array {	bitmap {filename = " "; preload = false; scale_factor = 1.3;} b_GainPos;  
			bitmap {filename = " "; preload = false; scale_factor = 1.3;} b_GainNeg; } a_Gain;
array {	bitmap {filename = " "; preload = false; scale_factor = 1.3;} b_LossPos;  
			bitmap {filename = " "; preload = false; scale_factor = 1.3;} b_LossNeg; } a_Loss;


#------------------------------------ Choice and feedback stimuli --------------------------------------#
# display the choice made by participant with arrow pointing at chosen symbol (pointing up)
array { arrow_graphic { coordinates = 0, -5 , 0, 5; line_width = 5; head_width = 50; head_type = head_flat; head_length = 30; } arrowLeft;
		  arrow_graphic { coordinates = 0, -5 , 0, 5; line_width = 5; head_width = 50; head_type = head_flat; head_length = 30; } arrowRight; } a_Arrows;

# Display the feedback bitmap (set filename later)
picture { bitmap {filename = " "; preload = false; scale_factor = 1;} b_Feedback; x = 0; y = 0; } p_Feedback; 
picture { text { caption = "######"; font_size = 48; } t_NoResponse; x = 0; y = 0; } p_NoResponse;

#--------------------------------------------------Stimuli events / Trial objects--------------------------#
		
trial{ 
		trial_duration = forever; trial_type = first_response;
		stimulus_event{
			picture p_Instructions1;
			time=0; code = 4; response_active = true; target_button = 3,4; } event_instructions;
		} trial_instructions;				# instruction before start experiment

trial{ 
		trial_duration = 3983; trial_type = fixed;
		picture p_InBetweenBlocks;
		time=0; code = 5; response_active = false; port_code = 5;
		} trial_inbetweenblocks;	# display text marking the beginning of new block
		
trial {
		trial_duration = 983; trial_type = fixed;
		picture p_NoResponse;
		time = 0; code = 6; response_active = false; port_code = 6;
		} trial_noresponse;		# display ###### to indicate a missed response

trial{ 
		trial_duration = 1; trial_type = fixed;			# duration will be set for each trial, random(2000, 4000) --> 2-4s
		picture p_Fixation;
		time=0; code = 7; response_active = false; port_code = 7;
		} trial_fixation;				# display fixation at the beginning of each new trial

trial{ 
		trial_duration = 1; trial_type = fixed;				# show cue for 2.5s
			picture p_Stimuli;
			time = 0; code = 8; response_active = false; port_code = 8;		
		} trial_Stimuli;				
		
trial{ 
		trial_duration = 983; trial_type = fixed;			# display feedback for 1s
		picture p_Feedback;
		time=0; code = 9; response_active = false; port_code = 9;
		} trial_Feedback;	