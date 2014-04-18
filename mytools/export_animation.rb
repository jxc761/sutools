require "sketchup"
# load ("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/export_animation.rb")
module CWRU
	
	def CWRU.export_all_animations
		options = CWRU.setting_export()
		return unless options
		eye=Sketchup.active_model.active_view.camera.eye.clone()
		target = Sketchup.active_model.active_view.camera.target.clone()
		up= Sketchup.active_model.active_view.camera.up.clone()
		CWRU.export_all(Sketchup.active_model, Sketchup.active_model.active_view, options)
		Sketchup.active_model.active_view.camera.set(eye,target,up)
	end
	
	
	def CWRU.export_selection_animations_validation()
		selection = Sketchup.active_model.selection
		if selection.count == 1 && CWRU.is_observer(selection[0])
			return MF_ENABLED
		end
		
		return MF_GRAYED
	end
	
	def CWRU.export_selection_animations
		options = CWRU.setting_export()
		return unless options
		
		observer=Sketchup.active_model.selection[0]
		
		
		eye=Sketchup.active_model.active_view.camera.eye.clone
		target = Sketchup.active_model.active_view.camera.target.clone
		up= Sketchup.active_model.active_view.camera.up.clone
		
		export_one_observer(Sketchup.active_model, Sketchup.active_model.active_view, observer, options)
		Sketchup.active_model.active_view.camera.set(eye,target,up)
	end
	
	def CWRU.setting_export()
		# http://en.wikipedia.org/wiki/Preferred_walking_speed 1.4m/s
		
		#First, let’s talk about what full-frame entails. Full-frame digital cameras use a sensor that’s equivalent in size to 35mm film (36 x 24mm), 
		prompts=["Forward", "Backward", "Left", "Right", 
			"Speed(m/s)", "Time(s)", 
			"FPS(fps)", "Width", "Height", 
			"FOV(degrees)"]  
		values=["on", "off", "off", "off", 
			"1.4", "5",
			"5", "180", "120", 
			"35"]
		flag="on|off" 
		enums=[flag, flag, flag, flag, nil,  nil,  nil, nil,  nil, nil]
		results=UI.inputbox(prompts,values,enums,"Animation Options")

		return nil unless results
		
		
		path_to_save_to = UI.savepanel("Export animation",  Sketchup.active_model.path, "")
		return nil unless path_to_save_to
		
		
		options = {
			"path_to_save_to"	=> path_to_save_to,
			"forward" 			=> results[0]=="on" ? true : false,
			"backward"			=> results[1]=="on" ? true : false,
			"left" 				=> results[2]=="on" ? true : false,
			"right" 			=> results[3]=="on" ? true : false,
			"distance" 			=> results[4].to_f,
			"speed" 			=> results[5].to_f,
			"fps" 				=> results[6].to_i,
			"width" 			=> results[7].to_i,
			"height" 			=> results[8].to_i,
			"fov" 				=> results[9].to_f.degrees
		}
		
		options.each {|key, value| puts "#{key} is #{value}" }
		return options
	end
	
	
	def CWRU.generate_observer_index(model)
	
		mapping = {}
		observer_definition = model.definitions["cwru_observer"]
		if observer_definition == nil
			return mapping
		end
		
		observers = observer_definition.instances
		observers.each_index{|index|
			observerId = CWRU.get_observerId(observers[index])
			mapping[observerId] = index
		}
		return mapping
		
	end
	
	def CWRU.generate_target_index(model)
		mapping = {}
		target_definition = model.definitions["cwru_target"]
		if target_definition == nil
			return mapping
		end
		
		targets = target_definition.instances
		targets.each_index{|index|
			targetId = CWRU.get_targetId(targets[index])
			mapping[targetId] = index
		}
		
		return mapping
	end
	
	def CWRU.export_all(model, view, options)
		path = options["path_to_save_to"]
		Dir.mkdir(path)
		
		observer_mapping= CWRU.generate_observer_index(model)
		target_mapping =  CWRU.generate_target_index(model)
		
		connections = CWRU.get_connections(model)
		connections.each{|connection|
			observer = connection[0]
			target = connection[1]
			observerId=CWRU.get_observerId(observer)
			targetId = CWRU.get_targetId(target)
			obs = observer_mapping[observerId]
			tar = target_mapping[targetId]
			cur_dir = File.join(path, "observer#{obs}_focalpoint#{tar}")
			Dir.mkdir(cur_dir)
			CWRU.export_one_pair(view, observer, target, options, cur_dir)
		}
	end
	
	def CWRU.export_one_observer(model, view, observer, options)
		path = options["path_to_save_to"]
		Dir.mkdir(path)
		connections = CWRU.get_connections(model)
		observerId = get_observerId(observer)
		observer_related_connections = CWRU.get_observer_related_connection(connections, observerId)
		
		observer_related_connections.each_index{|index|
			connection = observer_related_connections[index]
			target = connection[1]
			cur_dir = File.join(path, "focalpoint_#{index}")
			Dir.mkdir(cur_dir)
			CWRU.export_one_pair(view, observer, target, options, cur_dir)
		}
	end
	
	
	def CWRU.export_one_pair(view, observer, target, options, export_path, filename_prefix="")
		t_org	= observer.transformation
		target_position = CWRU.get_target_position(target)
		
		
		##########
		# movement direction
		#########
		v0 			= Geom::Vector3d.new 0, 0, 0
		left 		= v0 + t_org.xaxis
		right 		= v0 - t_org.xaxis
		forward 	= v0 - t_org.yaxis
		backward 	= v0 + t_org.yaxis
		
		speed			= options["speed"]  / options["fps"] # m/frame
		puts speed
		left.length= speed
		right.length= speed
		forward.length= speed
		backward.length= speed
		
		directions 	= {"left" => left, "right" => right, "forward" => forward, "backward" => backward}
		dnames 		= ["left", "right", "forward", "backward"]
		
		
		
		###########
		# camera setting
		########### 
		total_frame_number = ( (options["distance"] / options["speed"]) * options["fps"] ).to_i
		image_width = options["width"]
		image_height = options["height"]
		
		#loop for each direction
		dnames.each{ |dname|
			next unless options[dname]
			dv = directions[dname]
			mv = dv.transform(Geom::Transformation.scaling(speed.m))
			transform=Geom::Transformation.translation(mv)
			cur_dir = File.join(export_path, dname)
			Dir.mkdir(cur_dir)
			#loop for each frame
			(0...total_frame_number).each{ |frameId|
				cur_transform = observer.transformation	
				observer.transformation= transform * cur_transform
				
				up = CWRU.get_up(observer)
				eye_position = CWRU.get_eye_position(observer)
				view.camera.set(eye_position, target_position, up)
				
				# save image out
				filename=File.join(cur_dir, filename_prefix + "#{frameId}"+".jpg")
				Sketchup.set_status_text("Exporting frame #{frameId} to #{filename}")
				begin
					view.write_image(filename, image_width, image_height, true, 1.0)
				rescue
					UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
					raise
				end
			}
			
		}

		observer.transformation= t_org
	end
	
	
	# mt: transformation of observer at each frame
	def CWRU.export_one_sequence(view, observer, target, mt, nframe, image_width, image_hight, fov, export_path, prefix="")
		torg=observer.transformation
		
		#loop for each frame
		(0...nframe).each{ |frameId|
			cur_transform = observer.transformation	
			observer.transformation= mt * cur_transform
			
			up = CWRU.get_up(observer)
			eye_position = CWRU.get_eye_position(observer)
			view.camera.set(eye_position, target_position, up)
			
			# save image out
			filename=File.join(export_path, prefix + "#{frameId}"+".jpg")
			Sketchup.set_status_text("Exporting frame #{frameId} to #{filename}")
			begin
				view.write_image(filename, image_width, image_height, true, 1.0)
			rescue
				UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
				raise
			end
		}
		observer.transformation= torg
	end
	

end