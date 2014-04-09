require 'sketchup'

# load("/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/walkman.rb")
class CWalkman
	
	@@observer = nil
	@@target = nil
	@@observer_definition=nil
	@@observer_definition = Sketchup.active_model.definitions["cwru_observer"]
	if @@observer_definition == nil
		@@observer_definition =Sketchup.active_model.definitions.load "#{File.dirname(__FILE__)}/skp/cwru_observer.skp"
	end
	
	
	
	def CWalkman.observer=(obs)
		@@observer= obs
		return @@observer
	end
	
	def CWalkman.observer
		return @@observer
	end
	
	def CWalkman.target
		return @@target
	end
	
	def CWalkman.target=(t)
		@@target=t
		if @@observer!=nil
			p = @@target.position
			@@observer.set_attribute "walkman", "target_x", p.x
			@@observer.set_attribute "walkman", "target_y", p.y
			@@observer.set_attribute "walkman", "target_z", p.z
		end
		return @@target
	end
	
	def CWalkman.clear()
		@@observer = nil
		@@target = nil
	end
	
	
	
	def CWalkman.from_inst(inst)
		
		if inst.typename == "ComponentInstance" && @@observer_definition.name == inst.definition.name
			@@observer = inst
			dictionaries = @@observer.attribute_dictionaries
			if  dictionaries!=nil && dictionaries ["walkman"] != nil
				x = @@observer.get_attribute "walkman", "target_x"
				y = @@observer.get_attribute "walkman", "target_y"
				z = @@observer.get_attribute "walkman", "target_z"
				p =  Geom::Point3d.new(x, y, z)
				@@target =  Sketchup::InputPoint.new(p)
				return 2
			end
			
			return 1
		end
		
		return 0
	end
	
	
	def CWalkman.check(inst)
		
		if inst.typename == "ComponentInstance" && @@observer_definition.name == inst.definition.name
			return true
		else
			return false
		end
	end
	def CWalkman.move_observer(key)

		t_org = @@observer.transformation
		v0 = Geom::Vector3d.new 0,0,0
		case key
		when VK_LEFT
			tranform = Geom::Transformation.translation t_org.xaxis
		when VK_RIGHT
			v = v0- t_org.xaxis
			tranform = Geom::Transformation.translation v
		when VK_UP
			v = v0 - t_org.yaxis 
			tranform = Geom::Transformation.translation v
		when VK_DOWN
			tranform = Geom::Transformation.translation t_org.yaxis
		else
			tranform = Geom::Transformation.new
		end
		@@observer.transformation= tranform * t_org
	end
	
	def CWalkman.update(view)
		camera=view.camera
		camera.set(get_eye(), get_target(), get_up())
	end
	
	
	def CWalkman.get_eye()
		if @@observer == nil
			return nil
		end
		
		t = @@observer.transformation
		ve = t.zaxis.clone
		ve.length= 1.7.m
		eye = t.origin + ve
		return eye
	end

	def CWalkman.get_up()
		if @@observer == nil
			return nil
		end
		return @@observer.transformation.zaxis
	end
	
	def CWalkman.get_target()
		return @@target.position
	end
	
	
	def CWalkman.draw(view)
		if @@observer!=nil && @@target!=nil
			view.set_color_from_line(get_eye(),  get_target())
			view.draw_line(get_eye(),  get_target())
		end	
		
		if @@target!=nil
			@@target.draw(view)
		end
		
	end
	

	
end