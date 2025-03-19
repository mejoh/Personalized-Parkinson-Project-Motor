#--------------------------------------- Initiation ---------------------------------------#

pcl_file = "MotorTaskMainEv.pcl";
scenario = "Motor";

active_buttons = 4;
button_codes = 1,2,3,4;

default_background_color = 0, 0, 0;
default_font = "arial";
default_font_size = 24;
default_text_color = 235, 235, 235;

#Scanner trigger settings:
scenario_type =  fMRI;						# add '_emulation' when not connected to scanner
#scan_period = 1000; 							# only for emulation; time in ms between recorded triggers 1000 ms
pulse_code = 10;								# code passed on to the log file for a trigger (or emulated trigger)
pulses_per_scan = 1;   						# only used for non-emulation; when n, record every n'th trigger

response_matching = simple_matching;
default_output_port = 1;
write_codes = true;
pulse_width = 10;

begin;


#------------------------------------ Text Stimuli ---------------------------------------#

picture { text{ caption = "Wachten op scanner ..."; } t_Wait; x=0; y=0; } p_Wait;

picture { text { caption = "U krijgt zo 4 cirkels te zien. Deze representeren de 4 knoppen die u kunt drukken. \n
Sommige cirkels zijn gevuld en het aantal varieert tussen 1 en 3, zie hieronder. \n \n \n \n \n
Reageer z.s.m. door op een knop te drukken, die overeenkomt met een gevulde cirkel. \n \n
Soms zijn de cirkels die u ziet rood omlijnd zoals in het voorbeeld hieronder. \n \n \n \n \n
Reageer dan NIET en druk op GEEN knop."; } t_Instructions1; x = 0; y = 50;
			 bitmap {filename = "stim1.jpg"; preload = true; scale_factor = 0.27;} b_Ext; x = -400; y = 180;
			 bitmap {filename = "stim7.jpg"; preload = true; scale_factor = 0.27;} b_Int2; x = 0; y = 180;
			 bitmap {filename = "stim12.jpg"; preload = true; scale_factor = 0.27;} b_Int3; x = 400; y = 180;
			 bitmap {filename = "stim23.jpg"; preload = true; scale_factor = 0.27;} b_Catch; x = 0; y = -150;
			 text {	caption = "Druk op een knop om het experiment te starten"; font_color = 255,255,0; } t_Instructions3; x = 0; y = -350;} p_Instructions;

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
		picture p_Instructions;
		time=0; code = 5; response_active = true; target_button = 1,2,3,4; port_code = 5;
		} trial_instructions;		# instruction before start experiment

trial{ 
		trial_duration = 4000; trial_type = fixed;
		picture p_InBetweenBlocks;
		time=0; code = 6; response_active = false; port_code = 6;
		} trial_inbetweenblocks;	# display text marking the beginning of either rest baseline or new block

trial{ 
		trial_duration = 20000; trial_type = fixed;
		picture p_Fixation;
		time=0; code = 7; response_active = false; port_code = 7;
		} trial_baseline;				# display fixation cross during the baseline "block" lasting 20s

# For presentation of stimuli which are part of the trials
trial{ 
		trial_duration = 2000; trial_type = fixed;			# duration will be set for each trial, random(2000, 4000) --> 2-4s
		picture p_Fixation;
		time=0; code = 8; response_active = false; port_code = 8;
		} trial_fixation;				# display fixation at the beginning of each new trial

trial{ 
		trial_duration = 2000; trial_type = first_response;				# show cue until button press, but max 2s
		stimulus_event{
			picture p_Cue;
			time = 0; code = 9; response_active = true; target_button = 1; duration = response; port_code = 9; } event_cue;			# Target buttons are set later dependent on cue 
		} trial_cue;					# display the cue signaling button press  

