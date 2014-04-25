module CWRU
	##############

	###############
	def CWRU.show_all_observers
		model=Sketchup.active_model
		CWRU.show_all(model, "cwru_observer")
	end

	def CWRU.hide_all_observers
		model=Sketchup.active_model
		CWRU.hide_all(model, "cwru_observer")
	end

	def CWRU.hide_all_targets
		model=Sketchup.active_model
		CWRU.hide_all(model, "cwru_target")
	end

	def CWRU.show_all_targets
		model=Sketchup.active_model
		CWRU.show_all(model, "cwru_target")
	end

	def CWRU.redraw_links
		model = Sketchup.active_model
		definition = model.definitions["cwru_connections"]
	
		if definition == nil
			definition = model.definitions.add "cwru_connections"
		else
			definition.entities.clear!
		end
	
		connections = CWRU.get_connections(model)
		connections.each{ |connection|
			start_point = CWRU.get_eye_position(connection[0])
			end_point = CWRU.get_target_position(connection[1])
			definition.entities.add_cline(start_point, end_point)
		}
		model.entities.add_instance(definition, Geom::Transformation.new)
	end


	def CWRU.undraw_links
		model = Sketchup.active_model
		definition = model.definitions["cwru_connections"]
		if definition == nil
			definition = model.definitions.add "cwru_connections"
		end
		definition.entities.clear!
	end



	###################################################
	# core 
	###################################################	
	def CWRU.hide_all(model, def_name)
		definition = model.definitions[def_name]
		return unless definition 
		instances = definition.instances
		instances.each{ |inst|
			inst.visible= false
		
		}
	end


	def CWRU.show_all(model, def_name)
		definition = model.definitions[def_name]
		return unless definition 
	
		instances = definition.instances
		instances.each{ |inst|
			inst.visible= true
		
		}
	end

	def CWRU.hide_others(model, def_name, inst)
		definition = model.definitions[def_name]
		return unless definition 
		CWRU.hide_all(model, def_name)
		inst.visible= true
	end
	
end