require "sketchup.rb"
require  "#{File.dirname(__FILE__)}/walkman.rb"

module CWRU
	
	def CWRU.add_target(x, y, view)
		entities = Sketchup.active_model.entities
		inputpoint = view.inputpoint x,y

		# target must on a face or an edge
		if inputpoint.face == nil && inputpoint.edge == nil
			return nil
		end
		
		
		origin 	= inputpoint.position
		normal = Geom::Vector3d.new [0, 0, 1]
		if inputpoint.face != nil
			normal = inputpoint.face.normal
		end
		transformation = Geom::Transformation.new(origin, normal)
		return CWRU.new_target(view.model, transformation)
	end
	
	########################
	class CAddTargetTool

		def onLButtonDoubleClick(flags, x, y, view)	
			CWRU.add_target(x, y, view)
			view.invalidate 
		end
	end

	########################
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
				 normal = inputpoint.face.normal
			end
			transformation = Geom::Transformation.new(origin, normal)
			CWRU.new_observer(view.model, transformation)
		end
	
	end



	########################
	def CWRU.select_observer(x, y, view)
		ph = view.pick_helper
		ph.do_pick(x, y)
		best_entity = ph.best_picked
	
		if best_entity != nil	
			definition = Sketchup.active_model.definitions["cwru_observer"]
			if best_entity.typename == "ComponentInstance" && definition==best_entity.definition
				return best_entity
			end 
		end
		return nil
	end

	def CWRU.select_target(x, y, view)
		ph = view.pick_helper
		ph.do_pick(x, y)
		best_entity = ph.best_picked
	
		if best_entity != nil	
			definition = Sketchup.active_model.definitions["cwru_target"]
			if best_entity.typename == "ComponentInstance" && definition==best_entity.definition
				return best_entity
			end 
		end
		return nil
	end
	
	def CWRU.set_connection(connections, observer, target)
		cur_index = -1
		connections.each_index{ |index|
			connection = connections[index]
			if observer == connection[0] && target == connection[1]
				cur_index = index
				break
			end
		}
		if cur_index == -1
			connections << [observer, target]
		else
			connections.delete_at(cur_index)
		end	
		
		return connections
	end
	
	
	########################
	class CEditConnectionTool
		def activate
			# clear selection
			selection = Sketchup.active_model.selection
			selection.clear
			
			@connections = CWRU.get_connections(Sketchup.active_model)	
			@observer = nil
			@target = nil
			@mouse = nil
		end
		
		def onMouseMove(flags, x, y, view)
			@mouse = view.inputpoint(x,y)
			view.invalidate
		end
		
		
		def onCancel(reason, view)
			CWRU.save_connections(Sketchup.active_model, @connections)
			selection = Sketchup.active_model.selection
			selection.clear
			
			@connections = CWRU.get_connections(Sketchup.active_model)	
			@observer = nil
			@target = nil
			@mouse = nil
 		end
		
		def onLButtonUp(flags, x, y, view)
			case get_status
			when "pick_observer"
				onPickObserver(flags, x, y, view)
			when "pick_target"
				onPickTarget(flags, x, y, view)
			end
				
		end
		
		def onPickObserver(flags, x, y, view)
			reset()
			@observer = CWRU.select_observer(x, y, view)
			if @observer == nil
				reset()
			else
				selection = Sketchup.active_model.selection
				selection.clear
				selection.add(@observer)
			end
			view.invalidate 
		end
		
		def onPickTarget(flags, x, y, view)
			if get_status() != "pick_target"
				view.invalidate
				return
			end
	
			@target =  CWRU.select_target(x, y, view)
			if @target != nil
				@connections= CWRU.set_connection(@connections, @observer, @target)
			end
			
			view.invalidate
		end
		
		
		def get_status
			if @observer == nil
				return "pick_observer"
			else
				return "pick_target"
			end
		end
			
		def reset()
			# clear selection
			selection = Sketchup.active_model.selection
			selection.clear
			@observer = nil
			@target = nil
		end
		
		
		def draw(view)
			if get_status()== "pick_target"
				view.set_color_from_line(CWRU.get_eye_position(@observer), @mouse.position)
				view.draw_line(CWRU.get_eye_position(@observer), @mouse.position)
				@mouse.draw(view)
			end	
			
			draw_all_connections(view)
		end
		
		def draw_all_connections(view)	
		
			@connections.each{|connection|
				start_point = CWRU.get_eye_position(connection[0])
				end_point = CWRU.get_target_position(connection[1])
				view.set_color_from_line(start_point, end_point)
				view.draw_line(start_point,end_point)
			}
			
		end
		
		def deactivate(view)
			CWRU.save_connections(Sketchup.active_model, @connections)
			selection = Sketchup.active_model.selection
			selection.clear
			
			@observer = nil
			@target = nil
			@mouse = nil
			@connections = nil
			view.invalidate
		end
		
	end
	
	def CWRU.move_observer(key, observer)

		t_org = observer.transformation
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
		observer.transformation= tranform * t_org
	end
	
	def CWRU.look(view, observer, target)
		camera = view.camera
		
		eye_p = CWRU.get_eye_position(observer)
		up = CWRU.get_up(observer)
		target_p = CWRU.get_target_position(target)
		
		view.camera.set(eye_p, target_p, up)
	end
	
	def CWRU.selected_observer()
		selection = Sketchup.active_model.selection
		if selection.count == 1 && CWRU.is_observer(selection[0])
			return selection[0]
		end
		
		return nil
	end
	
	class CMoveObserverTool
		def activate
			@observer = CWRU.selected_observer()
			@connections = CWRU.get_connections(Sketchup.active_model)	
		end
		
		def deactivate(view)
			@observer = nil
			@connections = nil
			view.invalidate
		end
		
		def onLButtonUp(flags, x, y, view)
			@observer = CWRU.select_observer(x, y, view)
			view.invalidate
		end
		
		
	    def onKeyDown(key, repeat, flags, view)
			if @observer != nil
				CWRU.move_observer(key, @observer)
			end
	    end
		
		
		def draw(view)
			if @observer == nil
				return
			end
			
			if @observer != nil
				selection = Sketchup.active_model.selection
				selection.clear
				selection.add(@observer)
			end
			
			observerId = CWRU.get_observerId(@observer)
			connections = CWRU.get_observer_related_connection(@connections, observerId)
			connections.each{|connection|
				start_point = CWRU.get_eye_position(connection[0])
				end_point = CWRU.get_target_position(connection[1])
				view.set_color_from_line(start_point, end_point)
				view.draw_line(start_point,end_point)
			}
		end
	end
	
	
	class CLookThroughTool
		
		def activate
			@observer = nil
			@target = nil
			@mouse = nil
		end
		
		def onMouseMove(flags, x, y, view)
			@mouse = view.inputpoint(x,y)
			view.invalidate
		end
		
		def deactivate(view)
			@mouse = nil
			@observer = nil
			@target = nil
		end
		
		
		def onLButtonUp(flags, x, y, view)
			case get_status
			when "pick_observer"
				@observer = CWRU.select_observer(x, y, view)
			when "pick_target"
				@target =  CWRU.select_target(x, y, view)
			else
			end
			view.invalidate
		end
		
		
	
		def get_status
			if @observer == nil
				return "pick_observer"
			elsif @target == nil
				return "pick_target"
			else
				return "watching"
			end
		end
		
		
	    def onKeyDown(key, repeat, flags, view)
			if get_status() != "watching"
				return
			end
			
			
			CWRU.move_observer(key, @observer)
			
	    end
		
		def draw(view)
			if get_status() == "watching"
				selection = Sketchup.active_model.selection
				selection.clear
				selection.add(@target)
				CWRU.look(view, @observer, @target)
				return
			end
			
			if get_status() == "pick_target"
				# set observer in selected status
				selection = Sketchup.active_model.selection
				selection.clear
				selection.add(@observer)
				
				# draw reference line
				view.set_color_from_line(CWRU.get_eye_position(@observer), @mouse.position)
				view.draw_line(CWRU.get_eye_position(@observer), @mouse.position)
				@mouse.draw(view)
				
				return
			end
			
		end
	end
	

	def CWRU.redraw_links()
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
	
	
	def CWRU.undraw_links()
		model = Sketchup.active_model
		definition = model.definitions["cwru_connections"]
		if definition == nil
			definition = model.definitions.add "cwru_connections"
		end
		definition.entities.clear!
	end
end
