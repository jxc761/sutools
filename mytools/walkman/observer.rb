module CWRU
	
	def new_observer(model, transformation)
		definition = get_observer_definition(model)
		observer = model.entities.add_instance(definition, transformation)
		set_observerId(observer, Time.now.to_i.to_s)
		observer.add_observer(CEntityObserver)
	end
	
	def find_observer(model, observerId)
		observer_definition = model.definitions["cwru_observer"]
		if observer_definition == nil
			return nil
		end
		
		instances = observer_definition.instances
		instances.each{ |inst|
			id = inst.get_attribute "cwru_walkman", "targetId", Time.now.to_i.to_s	
			if id == observerId
				return inst
			end
		}
		return nil
	end

	def is_valid(model)
		observer_definition = model.definitions["cwru_observer"]
		return true if observer_definition == nil
		
		active_instance_count = 0
		instances = observer_definition.instances
		
		instances.each{ |inst|
			dict = inst.attribute_dictionary "cwru_walkman", false
			next if dict == nil
			if dict["isactive"] == "active"
				active_instance_count += 1
			end
		}
		return active_instance_count <= 1
	end
	
	
	def activate_observer(observer)
		old_activate = find_activate_observer(observer.model)
		deactivate_observer(old_activate)
		observer.set_attribute("cwru_walkman", "isactive", "active")
		
	end
	
	def deactivate_observer(observer)
		observer.set_attribute("cwru_walkman", "isactive", "deactive")
	end
	
	def set_targets(observer, targets)
		str = ""
		targets.each { |target|
			str << target.to_s
		}
		observer.set_attribute("cwru_walkman", "targets", str)
	end
	
	def get_targets(observer)
		
		str = observer.get_attribute("cwru_walkman", "targets", "")
		
		substrs = str.split("|")
		
		targets = []
		substrs.each {|substr|
			next if substr==""
			
			coords = substr.split(",")
			x = coords[0].to_l
			y = coords[1].to_l
			z = coords[2].to_l
			targets << Geom::Point3d.new(x, y, z)
		}
		return targets
	end
	
	
	
	
	
	def look_from_observer(view, observer, target)
		camera=view.camera
		camera.set(get_eye(), target, get_up())
	end

	
	
end
	