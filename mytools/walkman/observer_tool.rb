require "sketchup.rb"
# load "/Users/Jing/Library/Application Support/SketchUp 2013/SketchUp/Plugins/mytools/add_observer.rb"
class CAddObserverTool
	
	def onLButtonDoubleClick(flags, x, y, view)
		status = Sketchup.active_model.start_operation('add a new observer into scene', true)
		add_observer(x, y, view)
		view.invalidate 
		status = Sketchup.active_model.commit_operation
	end
	
	def add_observer(x, y, view)
		entities = Sketchup.active_model.entities
		transformation = nil
		inputpoint = view.inputpoint x,y
		origin 	= inputpoint.position
		normal = Geom::Vector3d.new [0, 0, 1]
		if inputpoint.face != nil 
			 normal = face.normal
		end
		transformation = Geom::Transformation.new(origin, normal)
		new_observer(view.model, transformation)
	end
	
end