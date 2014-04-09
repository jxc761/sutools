require "sketchup"
require "#{File.dirname(__FILE__)}/walkman.rb"


class CPlaceObserverTool
	
	@@observer_definition=nil
	@@observer_definition = Sketchup.active_model.definitions["cwru_observer"]
	if @@observer_definition == nil
		@@observer_definition =Sketchup.active_model.definitions.load "#{File.dirname(__FILE__)}/skp/cwru_observer.skp"
	end
	
	
	def deactivate(view)
		view.invalidate 
	end

	def onLButtonDoubleClick(flags, x, y, view)
		status = Sketchup.active_model.start_operation('place observer into the scene', true)
		place_observer(x, y, view)
		view.invalidate 
		status = Sketchup.active_model.commit_operation
	
	end

	def place_observer(x, y, view)
		entities = Sketchup.active_model.entities
		transformation = nil
		inputpoint = view.inputpoint x,y
		origin 	= inputpoint.position
		normal = Geom::Vector3d.new [0, 0, 1]
		if inputpoint.face != nil 
			 normal = inputpoint.face.normal
		 end
	
		transformation = Geom::Transformation.new(origin, normal)
		if CWalkman.observer == nil
			CWalkman.observer = entities.add_instance(@@observer_definition, transformation)
		else
			CWalkman.observer.transformation=transformation
		end
	end
	
	def draw(view)
		CWalkman.draw(view)
	end
end

class CMoverObserverTool
	def deactivate(view)
		view.invalidate 
	end

    def onKeyDown(key, repeat, flags, view)
		 CWalkman.move_observer(key)
		 view.invalidate 
    end
	
	def draw(view)
		view.zoom_extents
		CWalkman.draw(view)
	end
end


class  CShowWatchedTool
	def activate
		view = Sketchup.active_model.active_view
		CWalkman.update(view)
		
	end
	
	def deactivate(view)
		view.invalidate 
	end
	
    def onKeyDown(key, repeat, flags, view)
		 CWalkman.move_observer(key)
		 CWalkman.update(view)
    end
	
	def draw(view)
		CWalkman.draw(view)
	end
	
end


class CPickTargetTool

	def deactivate(view)
		view.invalidate 
	end

	def onLButtonDoubleClick(flags, x, y, view)
		inputpoint = view.inputpoint x,y 
		if( inputpoint.valid? )
			CWalkman.target=inputpoint
		else
			CWalkman.target=nil
		end
		
		view.invalidate 
	
	end
	
	def draw(view)
		CWalkman.draw(view)
	end
	
end
