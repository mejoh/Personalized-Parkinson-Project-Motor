####### INITIATION #######

pcl_file = "RewardTaskMain_fmri.pcl";
scenario = "RewardTask";

active_buttons = 2;
button_codes = 1,2;

default_background_color = 0, 0, 0;
default_font = "arial";
default_font_size = 24;
default_text_color = 235, 235, 235; 
#default_text_align = align_left;

scenario_type =  fMRI;						# add '_emulation' when not connected to scanner
#scan_period = 1000; 							# only for emulation; time between recorded triggers = 1000 ms
pulse_code = 10;								# code passed on to the log file for a trigger (or emulated trigger)
pulses_per_scan = 1;   						# only used for non-emulation; when n, record every n'th trigger

response_matching = simple_matching;
default_output_port = 1;
write_codes = true;
pulse_width = 10;

begin;


#--------------------------- Text stimuli for beginning and end of experiment ------------------------------#
picture { text{ caption = "Wachten op scanner ..."; } t_Wait; x=0; y=0; } p_Wait;

picture { text { caption = "U krijgt twee symbolen te zien. \n Selecteer één van de symbolen met de linker- of rechterknop. \n \n \n \n \n \n
Met de symbolen die u ziet, maakt u kans om geld te winnen, \n geld te verliezen of niets te krijgen. \n \n \n \n \n \n
Probeer zoveel mogelijk geld te verdienen. \n \n \n \n"; } t_Instructions1; x = 0; y = -50;
			 bitmap {filename = "buttonbox.jpg"; preload = true; scale_factor = 0.6;} button_box; x = 0; y = 150;
			 bitmap {filename = "win_.bmp"; preload = true; scale_factor = 0.7;} win; x = -400; y = -130;
			 bitmap {filename = "loss_.bmp"; preload = true; scale_factor = 0.7;} lose; x = 0; y = -130;
			 bitmap {filename = "neutral_.bmp"; preload = true; scale_factor = 0.7;} neut; x = 400; y = -130;
			 text {	caption = "Druk op een knop om het experiment te starten"; font_color = 255,255,0; } t_Instructions3; x = 0; y = -350;} p_Instructions;

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

picture { text{ caption = " "; } t_InBetweenBlocks; x=0; y=0; } p_InBetweenBlocks;		# to signal break of 5s

#--------------------------------------------------Stimuli events / Trial objects--------------------------#

trial{ 
		trial_duration = forever; trial_type = first_response;
		picture p_Instructions;
		time=0; code = 4; response_active = true; target_button = 1,2; port_code = 4;
		} trial_instructions;		# instruction before start experiment
		
trial{ 
		trial_duration = 3983; trial_type = fixed;
		picture p_InBetweenBlocks;
		time=0; code = 5; response_active = false; port_code = 5;
		} trial_inbetweenblocks;	# display text marking the beginning of new block
		
trial{ 
		trial_duration = 1; trial_type = fixed;
		picture p_InBetweenBlocks;
		time=0; code = 99; response_active = false; port_code = 99;
		} trial_inbetweenblocksend;
		
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