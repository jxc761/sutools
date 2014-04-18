module CWRU

	def CWRU.cmd_save_snapshot()
		path = UI.savepanel("Save snapshot", Sketchup.active_model.path, "snapshot.txt")
		if path!=nil && Sketchup.active_model != nil
			CWRU.save_snapshot(model, path)
		end
	end
	
	
	def CWRU.take_snapshot(model)	
		# connections
		connections = model.get_attribute("cwru_walkman", "connections", "")
		model.set_attribute("cwru_walkman", "snapshot_connections", connections)
		
		# targets
		targets = snapshot_instances(model, "cwru_target")
		model.set_attribute("cwru_walkman", "snapshot_targets", targets)
	
		# observers 
		observers = snapshot_instances(model, "cwru_observer")
		model.set_attribute("cwru_walkman", "snapshot_observers", observers)
		
		# randomly motion setting
		walk = model.get_attribute("cwru_walkman", "cwru_random_walk", "")
		model.set_attribute("cwru_walkman", "snapshot_random_walk", walk)
		
		# export setting
		animation = model.get_attribute("cwru_walkman", "cwru_animation", "")
		model.set_attribute("cwru_walkman", "snapshot_animation", animation)
	end
	
	
	def CWRU.snapshot_instances(model, def_name)
		attrs = ""
		
		definition = model.definitions[def_name]
		return attrs unless definition
		
		instances = definition.instances
		instances.each{|inst|
			id = get_cwru_id(model, inst)
			attrs << id << ":"
			
			t_mtx = inst.transformation.to_a
			t_mtx.each{ |t|
				attrs << t.to_s << ";" 
			}
			attrs << "|"
		}
		return attrs
	end
	

	def CWRU.recover_snapshot(model)
		 CWRU.reset_all(model)
		 snapshot = get_snapshot(model)
		 
		 
		 observers = CWRU.recover_instances_def(snapshot["observers"])
		 observers.each{ |obs|
			id = obs[0]
			transformation= obs[1]
		 	inst = CWRU.new_observer(model, transformation)
			CWRU.set_observerId(inst, id)
		 }
		 
		 
		 targets = CWRU.recover_instances_def(snapshot["targets"])
		 targets.each{ |t|
			id = t[0]
			transformation= t[1]
		 	inst = CWRU.new_target(model, transformation)
			CWRU.set_targetId(inst, id)
		 }
		 
 		model.set_attribute("cwru_walkman", "connections", snapshot["connections"])
 		model.set_attribute("cwru_walkman", "cwru_random_walk", snapshot["random_walk"])
		model.set_attribute("cwru_walkman", "cwru_animation", snapshot["animation"])
	end
	
	def CWRU.recover_instances_def(snapshot)
		instances_def = Array.new
		
		substrs = snapshot.split("|")
		substrs.each{ |substr|
			ss = substr.split(":")
			id = ss[0]
			
			transf_str = ss[1].split(";")
			transf_array = Array.new
			transf_str.each{|v|
				transf_array << v.to_f
			}
			transf = Geom::Transformation.new transf_array
			instances_def << [id, transf]
		}
		return 	instances_def
		
	end

	
	def CWRU.remove_all(model)
		CWRU.remove_all_connections(model)
		CWRU.remove_all_cwru_instances(model, "cwru_observer")
		CWRU.remove_all_cwru_instances(model, "cwru_target")
		CWRU.remove_random_walk_setting(model)
		CWRU.remove_animation_setting(model)
	end
	
	
	def CWRU.save_snapshot(model, path)
		file = File.open(path, "w")
		snapshot = get_snapshot(model)
		file.puts snapshot["observers"]
		file.puts snapshot["targets"]
		file.puts snapshot["connections"]
		file.puts snapshot["random_walk"]
		file.puts snapshot["animation"]
		file.close
	end
	
	
	def CWRU.load_snapshot(model, path)
		file = File.open(path, "r")
		lines = file.readlines
		file.close
		snapshot = {"observers" => lines[0], 
					"targets" => lines[1]
					"connections" => lines[2], 
					"random_walk" => lines[3]
					"animation"=>line[4]}
		CWRU.set_snapshot(model, snapshot)
	end
	
	def CWRU.get_snapshot(model)
		connections=model.get_attribute("cwru_walkman", "snapshot_connections", "")
		targets = model.get_attribute("cwru_walkman", "snapshot_targets", "")
		observers = model.get_attribute("cwru_walkman", "snapshot_observers", "")
		random_walk = model.get_attribute("cwru_walkman", "snapshot_random_walk", "")
		animation = model.get_attribute("cwru_walkman", "snapshot_animation", "")
		snapshot = ["targets"=>targets, "observers"=>observers, "connections" => connections,  "random_walk" => random_walk, "animation" => animation]
		return snapshot
	end

	def CWRU.set_snapshot(model, snapshot)
		model.set_attribute("cwru_walkman", "snapshot_connections", snapshot["connections"])
		model.set_attribute("cwru_walkman", "snapshot_targets", snapshot["targets"])
		model.set_attribute("cwru_walkman", "snapshot_observers", snapshot["observers"])
		model.set_attribute("cwru_walkman", "snapshot_random_walk", snapshot["random_walk"])
		model.get_attribute("cwru_walkman", "snapshot_animation",  snapshot["animation"])
	end
end