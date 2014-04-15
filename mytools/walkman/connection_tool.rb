module CWRU
	
	def select_observer(x, y, view)
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

	def select_target(x, y, view)
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
	
	def set_connection(connections, observer, target)
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
	end
	
	class CEditConnectionTool
		def activate
			@connections = get_connections(Sketchup.active_model)
			@observer = nil
			@target = nil
			@mouse = nil
		end
		
		def onMouseMove(flags, x, y, view)
			@mouse = view.inputpoint(x,y)
			view.invalidate
		end
	
		def onRButtonDoubleClick(flags, x, y, view)
			reset()
			@observer = select_observer(x, y, view)
			if @observer == nil
				reset()
			else
				selection = Sketchup.active_model.selection
				selection.clear
				selection.add(@observer)
			end
			view.invalidate 
		end
		
		def onLButtonDoubleClick(flags, x, y, view)
			if get_status() != "pick_target"
				view.invalidate
				return
			end
	
			@target =  select_target(x, y, view)
			if @target != nil
				set_connection(@connections, @observer, @target)
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
			@observer = nil
			@target = nil
			@mouse = nil
		end
		
		
		def draw(view)
			if get_status()== "pick_target"
				view.set_color_from_line(get_eye(), @mouse.position)
				view.draw_line(get_eye(), @mouse.position)
				@mouse.draw(view)
			end	
			
			draw_all_connections(view)
		end
		
		def draw_all_connections(view)	
			
			connections.each{|connection|
				start_point = get_eye_position(connection[0])
				end_point = get_target_position(connection[1])
				view.set_color_from_line(start_point, end_point)
				view.draw_line(start_point,end_point)
			}
			
		end
		
		def deactivate(view)
			save_connections(Sketchup.active_model, @connections)
			@observer = nil
			@target = nil
			@mouse = nil
			connections = []
			view.validate
		end
		
	end
end


