require "sketchup.rb"
# load "/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/add_observer.rb"
class CPlaceObserverTool
	def initialize
		@observer=nil
	end
	
	def activate
		definitions = Sketchup.active_model.definitions
		@observer_definition = definitions["cwru_observer"]
		if @observer_definition == nil
			@observer_definition =definitions.load "#{File.dirname(__FILE__)}/skp/cwru_observer.skp"
		end
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
			 normal = face.normal
		 end
		
		transformation = Geom::Transformation.new(origin, normal)
		@observer = entities.add_instance(@observer_definition, transformation)
	end
	
end

