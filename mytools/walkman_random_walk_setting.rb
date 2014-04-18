module CWRU
	
	def CWRU.regular_walk_setting()
		# http://en.wikipedia.org/wiki/Preferred_walking_speed 1.4m/s
		
		#First, let’s talk about what full-frame entails. Full-frame digital cameras use a sensor that’s equivalent in size to 35mm film (36 x 24mm), 
		prompts=["Forward", "Backward", "Left", "Right", 
			"Speed(m/s)", "Duration(s)"]  
		values=["on", "off", "off", "off", 
			"1.4", "5"]
		flag="on|off" 
		enums=[flag, flag, flag, flag, nil,  nil]
		results=UI.inputbox(prompts, values, enums, "Configure Regular Walk")

		return nil unless results
		
		options = {
			"forward" 			=> results[0]=="on" ? true : false,
			"backward"			=> results[1]=="on" ? true : false,
			"left" 				=> results[2]=="on" ? true : false,
			"right" 			=> results[3]=="on" ? true : false,
			"speed" 			=> results[4].to_f,
			"duration" 			=> results[5].to_f
		}
		
		options.each {|key, value| puts "#{key} is #{value}" }
		return options
	end
	
	def CWRU.random_walk_setting()
		# http://en.wikipedia.org/wiki/Preferred_walking_speed 1.4m/s
	
		#First, let’s talk about what full-frame entails. Full-frame digital cameras use a sensor that’s equivalent in size to 35mm film (36 x 24mm), 
		seed = Time.now.to_i
		prompts =["RandomSeed", "\#move_direction","Duration(s)", ]
		values  =[Time.now.to_i.to_s, "5",  "5"]
		results=UI.inputbox(prompts, values, "Configure Random Walking")

		return nil unless results
		random_walk_options = {
			"seed" 			=> results[0].to_i,
			"ndirections" 		=> results[1].to_i,
			"duration" 			=> results[2].to_f,
		}
	
		random_walk_options.each {|key, value| puts "#{key} is #{value}" }
		return random_walk_options
	end
	
	
	def CWRU.animate_setting()
		prompts =["FPS", "Width(pt)", "Height(pt)", "FOV(degrees)"]
		values  =["24", "180", "120", "35"]
		results =UI.inputbox(prompts, values, "Animation Setting")
		return nil unless results
		
		
		path_to_save_to = UI.savepanel("Export animation",  Sketchup.active_model.path, "")
		return nil unless path_to_save_to
		
		
		#"Speed(m/s)", "Time(s)", "\#frames"
		export_options = {
			"path_to_save_to"	=> path_to_save_to,
			"fps" 				=> results[0].to_i,
			"width" 			=> results[1].to_i,
			"height" 			=> results[2].to_i,
			"fov" 				=> results[3].to_f
		}
	
		export_options.each {|key, value| puts "#{key} is #{value}" }
		return export_options
		
	end
	
	def CWRU.hash_to_s(h)
		s = ""
		h.each{ |key, value|
			s << key.to_s << ":" << value.to_s << "|"			
		}
		return s
	end
	
	def CWRU.set_random_walk_setting(model, options)
 		attrs = ""
		attrs << options["seed"].to_s << ":"		
		attrs << options["ndirections"].to_s << ":" 
		attrs << options["duration"].to_s << ":" 	
		model.set_attribute("cwru_walkman", "cwru_random_walk", attrs)
	end
	
	def CWRU.get_random_walk_setting(model)
		attrs = model.get_attribute("cwru_walkman", "cwru_random_walk", "1234:2:2:")
		substrs = attrs.split(':')
		options = {}
		options["seed"] = substrs[0].to_i
		options["ndirections"] = substrs[1].to_i
		options["duration"] = substrs[2].to_f
		return options
	end
	
	def CWRU.set_animation_setting(model, options)
		attrs = ""
		attrs << options["path_to_save_to"].to_s << ":"
		attrs << options["fps" ].to_s << ":"
		attrs << options["width"].to_s << ":"
		attrs << options["height"].to_s << ":"		
		attrs << options["fov"].to_s<<":"
		model.set_attribute("cwru_walkman", "cwru_animation", attrs)
	end
	
	def CWRU.get_animation_setting(model)
		
		attrs = model.get_attribute("cwru_walkman", "cwru_animation", "./:24:180:120:35:")
		substrs = attrs.split(':')
		options = {}
		options["path_to_save_to"] = substrs[0].to_s
		options["fps"] = substrs[1].to_i
		options["width"] = substrs[2].to_i
		options["height"] = substrs[3].to_i
		options["fov"] = substrs[4].to_f
		return  options
	end
	


end
