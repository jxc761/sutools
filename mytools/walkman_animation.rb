require "sketchup"
# load ("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/walkman_animation.rb")
module CWRU
	
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
	def CWRU.generate_color_map()
		colormap = Array.new(125) 
		c = 0
		(0..4).each{|i|
			r = i * 63
			(0..4).each{|j|
				g = j * 63
				(0..4).each{|k|
					b = k * 63 
					colormap[c]  = [r, g, b]
					c = c + 1
				}
			}
		}
		return colormap
	end
	
	def CWRU.generate_target_color_mapping(model)
		 colormap=CWRU.generate_color_map()
		 idxmap = CWRU.generate_target_index(model)
		 
		 mapping = {}
		 idxmap.each{|key, value|	 
			 material = model.materials.add
			 material.color=colormap[value]
			 mapping[key]= material
		 }	 
		 return mapping
	end

	def CWRU.export_regular_walk_animations(model, view)
		
		animation_opts = CWRU.get_animation_setting(model)
		image_width = animation_opts["width"]
		image_height = animation_opts["height"]
		fov = animation_opts["fov"]
		fps = animation_opts["fps"]
		path_to_save_to = animation_opts["path_to_save_to"]
		
		walk_opts = CWRU.get_regular_walk_setting(model)
		duration = walk_opts["duration"]
		speed = walk_opts["speed"].m / (fps * 1.0)

		# begin to export 
		observer_mapping= CWRU.generate_observer_index(model)
		target_mapping =  CWRU.generate_target_index(model)
		srand(seed)
		connections = CWRU.get_connections(model)
		connections.each{|connection|
			observer = connection[0]
			target = connection[1]
			observerId=CWRU.get_observerId(observer)
			targetId = CWRU.get_targetId(target)
			obs = observer_mapping[observerId]
			tar = target_mapping[targetId]
			mts = CWRU.get_regular_walk_mts(observer, speed, walk_opts)
			CWRU.export_one_pair(view, observer, target, mts, nframe, image_width, image_height, fov, path_to_save_to, "C#{obs}_F#{tar}")
		}
		
	end
	
	
	def CWRU.get_regular_walk_mts(observer, speed, options)
		mts = Array.new
		t = observer.transformation
		
		
		###################################
		v0 			= Geom::Vector3d.new 0, 0, 0
		left 		= v0 + t_org.xaxis
		right 		= v0 - t_org.xaxis
		forward 	= v0 - t_org.yaxis
		backward 	= v0 + t_org.yaxis
		
		left.length= speed
		right.length= speed
		forward.length= speed
		backward.length= speed
		tl = Geom::Transformation.translation left
		tr = Geom::Transformation.translation right
		tf = Geom::Transformation.translation forward
		tb = Geom::Transformation.translation backward
		
		ts 	= {"left" => tl, "right" => tr, "forward" => tf, "backward" => tb}
		dnames 		= ["left", "right", "forward", "backward"]
		
		#loop for each direction
		dnames.each{ |dname|
			next unless options[dname]
			mts << ts[dname]
		}
		return mts		
	end
	
	
	
	def CWRU.redraw_random_walk_trajectories()
		
		model = Sketchup.active_model
		definition = model.definitions["cwru_trajectories"]
	
		if definition == nil
			definition = model.definitions.add "cwru_trajectories"
		else
			definition.entities.clear!
		end
		
		# load parameters
		walk_opts = CWRU.get_random_walk_setting(model)
		animation_opts = CWRU.get_animation_setting(model)
		
		walk_opts.each{|key, value| puts "#{key}: #{value}"}
		animation_opts.each{|key, value| puts "#{key}: #{value}"}
		seed = walk_opts["seed"]
		ndirections = walk_opts["ndirections"]
		duration = walk_opts["duration"]
		
	
		fps = animation_opts["fps"]
		
		
		nframe = (duration * fps).to_i
		
		slowest = walk_opts["slowest"].m / (fps * 1.0)
		fastest = walk_opts["fastest"].m / (fps * 1.0)
		
		# new materials
		
		
		srand(seed)
		connections = CWRU.get_connections(model)
		connections.each{|connection|
			observer = connection[0]
			#target = connection[1]
			#targetId = CWRU.get_targetId(target)
			#targetIndex = mapping[targetId]
			#mat = mapping[targetId]
			mts = CWRU.generate_random_mts(observer, slowest, fastest, ndirections)
			CWRU.draw_mts(definition.entities, observer, mts, nframe)
		}
		model.entities.add_instance(definition, Geom::Transformation.new)
	end
	
	def CWRU.draw_mts(entities, observer, mts, nframe)
		t_org = observer.transformation.clone()	
		start_point = observer.transformation.origin
		
		mts.each{ |mt|
			cur_transform= observer.transformation
			(0...nframe).each{ |frameId|
				cur_transform = mt * cur_transform
			}
			puts cur_transform.to_a
			
			observer.transformation=cur_transform 
			end_point = observer.transformation.origin
			entities.add_line(start_point, end_point)
			observer.transformation= t_org
			
		}
		observer.transformation= t_org
	end
	
	def CWRU.undraw_random_walk_trajectories()
		model = Sketchup.active_model
		definition = model.definitions["cwru_trajectories"]
		if definition == nil
			definition = model.definitions.add "cwru_trajectories"
		end
		definition.entities.clear!
	end
	
	def CWRU.export_random_walk_animations(model, view, walk_opts, animation_opts)
		
		# load parameters
		# walk_opts = CWRU.get_random_walk_setting(model)
		# animation_opts = CWRU.get_animation_setting(model)

		
		seed = walk_opts["seed"]
		ndirections = walk_opts["ndirections"]
		duration = walk_opts["duration"]
		
		
		image_width = animation_opts["width"]
		image_height = animation_opts["height"]
		fov = animation_opts["fov"]
		fps = animation_opts["fps"]
		path_to_save_to = animation_opts["path_to_save_to"]
		
		
		slowest = walk_opts["slowest"].m / (fps * 1.0)
		fastest = walk_opts["fastest"].m / (fps * 1.0)

		Dir.mkdir(path_to_save_to) unless File.exist?(path_to_save_to)
		
		nframe = (duration * fps).to_i
		
	
		
		# begin to export 
		srand(seed)
		connections = CWRU.get_connections(model)
		connections.each{|connection|
			#result = UI.messagebox('Continue?', MB_YESNO)
			#if result != IDYES
			#	return
		    #end
			
			observer = connection[0]
			target = connection[1]
			observerId=CWRU.get_observerId(observer)
			targetId = CWRU.get_targetId(target)
			# axis = observer.transformation
			# 
			mts = CWRU.generate_random_mts(observer, slowest, fastest, ndirections)
			CWRU.export_one_pair(view, observer, target, mts, nframe, image_width, image_height, fov, path_to_save_to, "C#{observerId}_F#{targetId}_")
		}
		
	end
	
	
	def CWRU.generate_random_mts(observer, slowest, fastest, ndirections)
		t = observer.transformation
		mts = Array.new(ndirections)
		(0...ndirections).each{ |i|
			angle = rand * 2 * 3.14
			rotation = Geom::Transformation.rotation t.origin, t.zaxis, angle
			direction = t.xaxis.transform rotation
			if direction.length - 1 > 0.001 && direction.length - 1 < 0.001 
				puts "generate_random_direction error!!!"
			end
			speed= rand * (fastest - slowest) + slowest
			direction.length= speed
			mts[i] = Geom::Transformation.translation direction
			
			# puts "angle:#{angle}, speed:#{speed}"
		}
		return mts
	end
	
	# mts: moving transformations 
	# names: 
	def CWRU.export_one_pair(view, observer, target, mts, nframe, image_width, image_height, fov, export_path, prefix="")
	
		mts.each_index{ |index|
			mt = mts[index]
	
			cur_dir = File.join(export_path, prefix + "D#{index}")
			if File.exist?(cur_dir)
				puts "#{cur_dir} exists!"
				next
			end
			Dir.mkdir(cur_dir)		
			CWRU.export_one_sequence(view, observer, target, mt, nframe, image_width, image_height, fov, cur_dir)
		}
		
	end
	

	# mt: transformation of observer at each frame
	def CWRU.export_one_sequence(view, observer, target, mt, nframe, image_width, image_height, fov, export_path, prefix="")
		torg=observer.transformation
		target_position = CWRU.get_target_position(target)
		
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
			CWRU.write_image(view, filename, image_width, image_height)
		}
		
		observer.transformation= torg
	end
	
	def CWRU.write_image(view, filename, image_width, image_height)
		begin
			view.write_image(filename, image_width, image_height, true, 1.0)
		rescue
			UI.messagebox("Error exporting animation frame.  Check animation parameters and retry.")
			raise
		end
	end
	

end